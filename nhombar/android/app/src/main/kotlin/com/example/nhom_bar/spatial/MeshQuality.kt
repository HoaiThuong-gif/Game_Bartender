package com.example.nhom_bar.spatial

import kotlin.math.*

/** Weld coincident vertices for topology checks; retain real measured geometry only. */
object MeshQuality {
    data class Result(val mesh:ScanMesh,val retained:Float,val boundary:Float,val nonManifold:Int) {
        val acceptable get() = mesh.triangles>=300 && retained>=.5f && nonManifold==0
        val complete get() = mesh.triangles>=1000 && retained>=.85f && boundary<.12f && nonManifold==0
        val summary get() = "${mesh.triangles} tam giác · giữ ${(retained*100).toInt()}% bề mặt liên tục · ${(boundary*100).toInt()}% cạnh hở"
    }
    private data class Point(val x:Int,val y:Int,val z:Int)
    fun evaluate(input:ScanMesh):Result {
        val v=input.vertices
        require(v.isNotEmpty() && v.size%9==0 && v.all {it.isFinite()})
        val extent=(v.maxOrNull()!!-v.minOrNull()!!).coerceAtLeast(.01f)
        val epsilon=extent*1e-5f
        val points=HashMap<Point,Int>();val faces=ArrayList<IntArray>();val source=ArrayList<Int>()
        val unique=HashSet<List<Int>>()
        for(t in 0 until input.triangles) {
            val ids=IntArray(3) {j->val i=t*9+j*3
                points.getOrPut(Point((v[i]/epsilon).roundToInt(),(v[i+1]/epsilon).roundToInt(),(v[i+2]/epsilon).roundToInt())) {points.size}}
            if(ids.toSet().size<3 || !unique.add(ids.sorted()))continue
            val p=t*9;val ax=v[p+3]-v[p];val ay=v[p+4]-v[p+1];val az=v[p+5]-v[p+2]
            val bx=v[p+6]-v[p];val by=v[p+7]-v[p+1];val bz=v[p+8]-v[p+2]
            if((ay*bz-az*by).pow(2)+(az*bx-ax*bz).pow(2)+(ax*by-ay*bx).pow(2)<epsilon.pow(4))continue
            faces.add(ids);source.add(t)
        }
        if(faces.isEmpty())return Result(ScanMesh(floatArrayOf(),floatArrayOf()),0f,1f,0)
        val parent=IntArray(faces.size) {it}
        fun root(i:Int):Int {var k=i;while(parent[k]!=k){parent[k]=parent[parent[k]];k=parent[k]};return k}
        fun edge(a:Int,b:Int)=(min(a,b).toLong() shl 32) or max(a,b).toLong()
        val owner=HashMap<Long,Int>()
        for((i,f) in faces.withIndex())for(j in 0..2) {
            val previous=owner.putIfAbsent(edge(f[j],f[(j+1)%3]),i)
            if(previous!=null)parent[root(i)]=root(previous)
        }
        val counts=IntArray(faces.size);for(i in faces.indices)counts[root(i)]++
        val largest=counts.indices.maxByOrNull {counts[it]}!!
        val kept=faces.indices.filter {root(it)==largest}
        val edges=HashMap<Long,Int>()
        for(i in kept)for(j in 0..2){val key=edge(faces[i][j],faces[i][(j+1)%3]);edges[key]=(edges[key]?:0)+1}
        fun floats(data:FloatArray,stride:Int)=FloatArray(kept.size*stride) {i->data[source[kept[i/stride]]*stride+i%stride]}
        val mesh=ScanMesh(floats(v,9),floats(input.colors,9),input.uv?.let {floats(it,6)},input.texture)
        return Result(mesh,kept.size.toFloat()/input.triangles,
            edges.values.count {it==1}.toFloat()/edges.size.coerceAtLeast(1),edges.values.count {it>2})
    }
}
