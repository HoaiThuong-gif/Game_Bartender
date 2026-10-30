import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Bản THỬ NGHIỆM Three.js độc lập với gameplay (KHÔNG phải bản multiplayer).
/// - Không thay đổi RoomRepository, Firebase hoặc BartenderController.
/// - Ban đầu bàn TRỐNG, bấm 'Sinh cam 3D' để kiểm tra vật thể.
/// - Kéo bám ngón tay, giữ điểm chạm, vuốt nhanh sang trái/phải để thử chuyền.
/// - V5.1: kéo bằng proxy nhẹ khi GPU WebGL bị chậm; thả về model 3D thực.
/// - Chất liệu, ánh sáng cải thiện. Vẫn là prototype WebGL, không phải final game.
/// - Bản preview: chưa kết nối Firebase hay BartenderController.
/// - HTML nhúng trong Dart; Three.js tải qua CDN, CẦN INTERNET ở bản thử này.
class Bartender3DPreviewScreen extends StatefulWidget {
  const Bartender3DPreviewScreen({super.key});

  @override
  State<Bartender3DPreviewScreen> createState() =>
      _Bartender3DPreviewScreenState();
}

class _Bartender3DPreviewScreenState
    extends State<Bartender3DPreviewScreen> {
  late final WebViewController _web;
  bool _sceneReady = false;
  int _itemCount = 0;
  String? _error;
  String _hint = 'Đang tải Three.js qua Internet...';

  @override
  void initState() {
    super.initState();
    _web = WebViewController();
    unawaited(_prepareScene());
  }

  Future<void> _prepareScene() async {
    try {
      await _web.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _web.setBackgroundColor(const Color(0xFFE8C999));
      await _web.addJavaScriptChannel(
        'Game3D',
        onMessageReceived: (message) {
          if (!mounted) return;
          try {
            final event = jsonDecode(message.message) as Map<String, dynamic>;
            final type = event['type'];
            setState(() {
              if (type == 'ready') {
                _sceneReady = true;
                _hint = 'Bàn đã sẵn sàng — sinh cam để thử bám tay.';
              } else if (type == 'count') {
                _itemCount = (event['count'] as num).toInt();
                if (_itemCount == 0) {
                  _hint = 'Bàn đã sẵn sàng — sinh cam để thử bám tay.';
                } else {
                  _hint = 'Giữ cam rồi kéo nhanh · Vuốt trái/phải để thử chuyền.';
                }
              } else if (type == 'moved') {
                _hint = 'Đã thả cam xuống bàn.';
              } else if (type == 'swipe') {
                final direction = event['direction'] == 'left' ? 'TRÁI' : 'PHẢI';
                _hint = 'Đã thử chuyền $direction! (Chưa nối multiplayer)';
              } else if (type == 'selected') {
                _hint = 'Giữ và kéo cam · Vuốt nhanh hoặc thả sát mép để chuyền.';
              } else if (type == 'error') {
                _error = event['message']?.toString() ?? 'Lỗi WebGL';
              }
            });
          } catch (_) {
            setState(() => _error = 'Không nhận được dữ liệu Three.js.');
          }
        },
      );
      await _web.loadHtmlString(_sceneHtml);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _run(String js) {
    if (!_sceneReady) return;
    unawaited(_web.runJavaScript(js).catchError((Object error) {
      if (mounted) setState(() => _error = error.toString());
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7B485),
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _web)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoPanel(
                        heading: 'BARTENDER · THREE.JS V5.1',
                        subtitle: _hint,
                      ),
                      _InfoPanel(
                        heading: 'VẬT THỂ · $_itemCount',
                        subtitle: _sceneReady ? 'Chế độ bám tay (ưu tiên phản hồi)' : 'Đang tải...',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.add_circle_outline,
                        text: 'SINH CAM 3D',
                        enabled: _sceneReady,
                        onPressed: () => _run('window.game3D.spawnOrange();'),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        text: 'DỌN BÀN',
                        enabled: _sceneReady && _itemCount > 0,
                        onPressed: () => _run('window.game3D.clear();'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_error != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 78,
              child: Material(
                color: const Color(0xFF9B3131),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.heading, required this.subtitle});
  final String heading;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 285),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEFFFF6E2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFBA8957), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 9, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            heading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF60361B),
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF876647), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.text,
    required this.enabled,
    required this.onPressed,
  });
  final IconData icon;
  final String text;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 19),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(138, 44),
        backgroundColor: const Color(0xFFFFCC61),
        foregroundColor: const Color(0xFF5C351B),
        disabledBackgroundColor: const Color(0xFFD8C6A2),
        disabledForegroundColor: const Color(0xFF8D8069),
        elevation: 4,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: const BorderSide(color: Color(0xFFA86B32), width: 1.4),
        ),
      ),
    );
  }
}

// Raw string: JavaScript is preserved literally (no Dart string interpolation).
// Real 3D scene (Three.js) with 2D composited drag proxy ONLY while dragging.
// Helps touch responsiveness on Android Emulator low-FPS GPU.
const String _sceneHtml = r'''
<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"/>
<style>
*{box-sizing:border-box}html,body{width:100%;height:100%;margin:0;overflow:hidden;touch-action:none;user-select:none;-webkit-user-select:none}
body{background:radial-gradient(ellipse at 50% 35%,#f9e8c7 0%,#eed4ab 68%,#c99b65 100%);}
#stage{display:block;width:100%;height:100%;touch-action:none;cursor:grab;outline:0}
#stage.drag{cursor:grabbing}
#metrics{position:absolute;right:10px;bottom:7px;color:#fff0d6;background:rgba(71,41,20,.86);padding:4px 8px;border-radius:8px;font:600 11px sans-serif;pointer-events:none}
#left,#right{position:absolute;top:42%;transform:translateY(-50%);background:rgba(247,222,173,.88);border:2px solid #a87b49;color:#643a19;border-radius:12px;padding:10px 8px;opacity:0;pointer-events:none;transition:opacity 75ms;font:800 12px system-ui;text-align:center}
#left{left:7px}#right{right:7px}#left.show,#right.show{opacity:1}#left.active,#right.active{border-color:#12a075;background:#a1f3cf}

/* Hiển thị vật thể ở lớp compositor trong lúc kéo: không phải vẽ lại WebGL mỗi pointermove. */
#dragProxy{position:fixed;left:0;top:0;z-index:4;display:none;pointer-events:none;
  transform:translate3d(-9999px,-9999px,0);will-change:transform;
  contain:layout style paint;touch-action:none}
#dragProxy svg{display:block;width:100%;height:100%;overflow:visible}
#error{display:none;position:absolute;left:12%;right:12%;top:39%;background:#fff3db;border:2px solid #b66340;color:#773a20;padding:13px;border-radius:13px;font:13px system-ui;text-align:center;line-height:1.5}
</style>
</head>
<body>
<canvas id="stage"></canvas>
<div id="left">⬅<br>TRÁI</div><div id="right">PHẢI<br>➡</div>
<div id="dragProxy" aria-hidden="true">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 143" role="presentation">
  <defs>
    <radialGradient id="orangeBody" cx="31%" cy="22%" r="81%">
      <stop offset="0" stop-color="#ffcf60"/><stop offset=".24" stop-color="#ffab2b"/>
      <stop offset=".75" stop-color="#fb7a09"/><stop offset="1" stop-color="#b74b09"/>
    </radialGradient>
    <linearGradient id="leafTint" x1=".1" y1=".1" x2="1" y2="1">
      <stop stop-color="#81d64e"/><stop offset="1" stop-color="#178d37"/>
    </linearGradient>
  </defs>
  <ellipse cx="60" cy="129" rx="42" ry="10" fill="#5b331a" opacity=".19"/>
  <circle cx="60" cy="73" r="45" fill="url(#orangeBody)"/>
  <path d="M59 36 Q55 25 61 17" stroke="#725021" stroke-width="6" stroke-linecap="round" fill="none"/>
  <path d="M60 27 Q30 1 20 25 Q37 45 60 27Z" fill="url(#leafTint)"/>
  <path d="M62 27 Q91 4 105 25 Q85 44 62 27Z" fill="url(#leafTint)"/>
  <circle cx="45" cy="82" r="4" fill="#572913"/><circle cx="75" cy="82" r="4" fill="#572913"/>
  <path d="M54 95 Q60 101 66 95" stroke="#6b3013" stroke-width="3" fill="none" stroke-linecap="round"/>
  <ellipse cx="43" cy="58" rx="9" ry="6" fill="white" opacity=".28" transform="rotate(-25 43 58)"/>
</svg>
</div>
<div id="metrics">THREE.JS · đang tải...</div><div id="error"></div>
<script type="module">
(async () => {
'use strict';
const canvas = document.getElementById('stage');
const metrics = document.getElementById('metrics');
const leftHint = document.getElementById('left');
const rightHint = document.getElementById('right');
const errorBox = document.getElementById('error');
const dragProxy = document.getElementById('dragProxy');
const tell = (type, extra = {}) => {
  try { window.Game3D?.postMessage(JSON.stringify({type, ...extra})); } catch (_) {}
};
const reportError = (error) => {
  const message = (error?.message || String(error));
  errorBox.style.display = 'block';
  errorBox.textContent = 'Không tải được Three.js / WebGL: ' + message + '. Hãy kiểm tra Internet của máy ảo rồi chạy lại.';
  tell('error', {message});
};
window.addEventListener('error', (e) => reportError(e.error || e.message));
window.addEventListener('unhandledrejection', (e) => reportError(e.reason));
let THREE;
try {
  // Bản so sánh có CDN. Phiên bản chính thức sẽ đóng gói thư viện trong asset.
  THREE = await import('https://cdn.jsdelivr.net/npm/three@0.179.1/build/three.module.js');
} catch (e) { reportError(e); return; }
let renderer;
try {
  renderer = new THREE.WebGLRenderer({
    canvas, antialias: false, alpha: false, powerPreference: 'high-performance',
    depth: true, stencil: false, preserveDrawingBuffer: false
  });
} catch (e) { reportError(e); return; }
renderer.setPixelRatio(1.15); // không nhân với devicePixelRatio (thường rất cao trong emulator)
renderer.setClearColor(0xf1dcba, 1);
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.NoToneMapping;
renderer.shadowMap.enabled = false; // bóng giả tiết kiệm GPU

const scene = new THREE.Scene();
scene.background = new THREE.Color(0xf1dcba);
const camera = new THREE.OrthographicCamera(-5,5,3,-3,.1,100);
camera.position.set(0,8.8,8.0);
camera.lookAt(0,.13,0);
const ambient = new THREE.HemisphereLight(0xfff3d9, 0xa77642, 2.1);
scene.add(ambient);
const sun = new THREE.DirectionalLight(0xffefd0, 1.6);
sun.position.set(-4,10,4);
scene.add(sun);

// Vân gỗ tạo một lần, không vẽ vân gỗ bằng shader nặng mỗi frame.
function woodTexture() {
  const c=document.createElement('canvas'); c.width=1024;c.height=512;
  const ctx=c.getContext('2d');
  ctx.fillStyle='#c88342';ctx.fillRect(0,0,c.width,c.height);
  let seed=15;
  const rnd=()=>{seed=(seed*1664525+1013904223)>>>0;return seed/4294967296};
  for (let i=0;i<350;i++) {
    const y=rnd()*512, amp=1+rnd()*2, freq=.006+rnd()*.006;
    ctx.beginPath();
    for(let x=0;x<=1024;x+=12){
      const dy=Math.sin(x*freq+i*.31)*amp;
      if(x===0)ctx.moveTo(x,y+dy);else ctx.lineTo(x,y+dy);
    }
    ctx.strokeStyle=i%3===0?'rgba(109,52,17,.095)':'rgba(253,206,143,.115)';
    ctx.lineWidth=.4+rnd()*1.8;ctx.stroke();
  }
  const g=ctx.createLinearGradient(0,0,1024,512);
  g.addColorStop(0,'rgba(255,221,159,.19)');g.addColorStop(.5,'rgba(255,225,168,.025)');g.addColorStop(1,'rgba(105,50,18,.09)');
  ctx.fillStyle=g;ctx.fillRect(0,0,1024,512);
  const tex = new THREE.CanvasTexture(c);
  tex.colorSpace=THREE.SRGBColorSpace;
  tex.anisotropy=2;
  return tex;
}
const top = new THREE.Mesh(
  new THREE.BoxGeometry(11.1,.24,5.55),
  [
    new THREE.MeshLambertMaterial({color:0x935529}),
    new THREE.MeshLambertMaterial({color:0x935529}),
    new THREE.MeshLambertMaterial({map:woodTexture()}),
    new THREE.MeshLambertMaterial({color:0x714023}),
    new THREE.MeshLambertMaterial({color:0x87451e}),
    new THREE.MeshLambertMaterial({color:0x87451e})
  ]
);
top.position.y=.16;scene.add(top);
const trim = new THREE.Mesh(new THREE.BoxGeometry(11.35,.13,5.8),new THREE.MeshLambertMaterial({color:0x8b4926}));
trim.position.y=.005;scene.add(trim);
const footing = new THREE.Mesh(new THREE.BoxGeometry(11.28,.13,5.7),new THREE.MeshLambertMaterial({color:0x5a2e18}));
footing.position.y=-.1;scene.add(footing);
// Không có chân bàn. Chỉ mép gỗ bao quanh mặt bàn.
const fruits = [];
const bodies=[];
const fruitGeo=new THREE.SphereGeometry(.48,16,12);
const fruitMat=new THREE.MeshLambertMaterial({color:0xff8e1a});
const leafGeo=new THREE.SphereGeometry(1,9,7);
const leafMat=new THREE.MeshLambertMaterial({color:0x43aa4a});
const eyeGeo=new THREE.SphereGeometry(.055,7,6);
const eyeMat=new THREE.MeshBasicMaterial({color:0x4f270e});
const stemGeo=new THREE.CylinderGeometry(.045,.065,.22,7);
const stemMat=new THREE.MeshLambertMaterial({color:0x665021});
const shadowGeo=new THREE.CircleGeometry(.57,24);
const shadowMat=new THREE.MeshBasicMaterial({color:0x482b17,transparent:true,opacity:.21,depthWrite:false});
function createFruit(x,z) {
  const group=new THREE.Group();group.position.set(x,.78,z);
  const body=new THREE.Mesh(fruitGeo,fruitMat);
  body.scale.set(1,1.02,.98);
  body.userData.fruit=group;
  group.add(body);
  bodies.push(body);
  const stem=new THREE.Mesh(stemGeo,stemMat);stem.position.set(0,.49,0);group.add(stem);
  for (const sign of [-1,1]) {
    const leaf=new THREE.Mesh(leafGeo,leafMat);
    leaf.scale.set(.24,.065,.14);
    leaf.position.set(sign*.15,.54,.02);leaf.rotation.z=sign*.32;
    group.add(leaf);
  }
  for (const sign of [-1,1]) {
    const eye=new THREE.Mesh(eyeGeo,eyeMat);
    eye.position.set(sign*.14,-.055,.446);group.add(eye);
  }
  const mouth=new THREE.Mesh(new THREE.SphereGeometry(.038,7,5),eyeMat);
  mouth.position.set(0,-.20,.448);mouth.scale.set(1.1,.40,.4);group.add(mouth);
  const shadow=new THREE.Mesh(shadowGeo,shadowMat);
  shadow.rotation.x=-Math.PI/2;shadow.position.set(x,.285,z);scene.add(shadow);
  group.userData.shadow=shadow;
  scene.add(group);fruits.push(group);return group;
}
let canvasBounds = canvas.getBoundingClientRect();
const raycaster=new THREE.Raycaster();
const mouse=new THREE.Vector2();
const plane=new THREE.Plane(new THREE.Vector3(0,1,0),-.86);
const hitPoint=new THREE.Vector3();
function getNdc(e) {
  const rect=canvasBounds;
  mouse.set(((e.clientX-rect.left)/rect.width)*2-1,-((e.clientY-rect.top)/rect.height)*2+1);
  raycaster.setFromCamera(mouse,camera);
}
function surfacePoint(e){getNdc(e);return raycaster.ray.intersectPlane(plane,hitPoint)?hitPoint:null;}
let active=null;
let frameQueued=false;
let isDragging=false;
let lastFpsTime=performance.now();
let sampleFps=0;
let movingFrames=0;
const onFrameDone=[];
function requestRender(onComplete) {
  if (onComplete) onFrameDone.push(onComplete);
  if (frameQueued) return;
  frameQueued=true;
  requestAnimationFrame(()=>{
    frameQueued=false;
    renderer.render(scene,camera);
    if (isDragging) movingFrames++;
    for(const f of onFrameDone.splice(0)) f();
  });
}
// Chuyển toạ độ 3D thành pixel trong WebView (để sprite kéo không bị lệch tâm).
const projectedPoint = new THREE.Vector3();
const projectedRadius = new THREE.Vector3();
function fruitScreenInfo(group) {
  const r=canvas.getBoundingClientRect();
  projectedPoint.copy(group.position).project(camera);
  projectedRadius.set(group.position.x+.48,group.position.y,group.position.z).project(camera);
  return {
    x:r.left+(projectedPoint.x+1)*r.width*.5,
    y:r.top+(1-projectedPoint.y)*r.height*.5,
    width:Math.max(44,Math.min(115,Math.abs(projectedRadius.x-projectedPoint.x)*r.width*1.18))
  };
}
function setProxyAt(x,y) {
  if (!active) return;
  const w=active.proxyW;
  // Chạm vào chỗ nào trên quả cam thì giữ nguyên chỗ đó khi kéo.
  const cx=x+active.pixelOffsetX;
  const cy=y+active.pixelOffsetY;
  dragProxy.style.transform=`translate3d(${(cx-w*.5).toFixed(1)}px,${(cy-w*.61).toFixed(1)}px,0)`;
}
function showProxy(group,e) {
  const p=fruitScreenInfo(group);
  active.pixelOffsetX=p.x-e.clientX;
  active.pixelOffsetY=p.y-e.clientY;
  active.proxyW=p.width;
  dragProxy.style.width=p.width+'px';
  dragProxy.style.height=(p.width*1.192)+'px';
  setProxyAt(e.clientX,e.clientY);
  dragProxy.style.display='block';
}
function statusUpdate(){
  const now=performance.now();
  const dt=now-lastFpsTime;
  if(dt>=1000){
    sampleFps=isDragging?Math.round(movingFrames*1000/dt):0;
    movingFrames=0;lastFpsTime=now;
    // Đang kéo bằng lớp hình nhẹ: 3D tạm ngừng render, đừng gọi số 0 FPS là giật.
    metrics.textContent=isDragging
      ? 'BÁM TAY · 3D tạm dừng vẽ khi kéo'
      : `THREE.JS · nghỉ · ${fruits.length} vật thể`;
  }
}
setInterval(statusUpdate,1000);
function resize(){
  canvasBounds=canvas.getBoundingClientRect();
  const width=Math.max(1,canvas.clientWidth),height=Math.max(1,canvas.clientHeight);
  const aspect=width/height;
  // Bàn chiếm khoảng 92–95% bề ngang trên màn hình ngang Pixel 7.
  const heightUnits=5.35;
  const widthUnits=heightUnits*aspect;
  camera.left=-widthUnits/2;camera.right=widthUnits/2;
  camera.top=heightUnits/2;camera.bottom=-heightUnits/2;
  camera.updateProjectionMatrix();
  renderer.setSize(width,height,false);
  requestRender();
}
window.addEventListener('resize',resize,{passive:true});

function hints(dir,armed){
  leftHint.className=dir==='left'?'show'+(armed?' active':''):'';
  rightHint.className=dir==='right'?'show'+(armed?' active':''):'';
}
function pointerDown(e){
  if(active) return;
  getNdc(e);
  const hits=raycaster.intersectObjects(bodies,false);
  if(hits.length===0)return;
  const group=hits[0].object.userData.fruit;
  const worldPoint=surfacePoint(e);
  if(!worldPoint)return;
  e.preventDefault();
  canvas.setPointerCapture(e.pointerId);
  const now=performance.now();
  active={group,id:e.pointerId,offsetX:group.position.x-worldPoint.x,
    offsetZ:group.position.z-worldPoint.z,startX:e.clientX,
    startTime:now,history:[{x:e.clientX,t:now}],
    pixelOffsetX:0,pixelOffsetY:0,proxyW:60};
  isDragging=true;
  canvas.classList.add('drag');
  // Lấy ảnh minh hoạ nét và di chuyển qua compositor khi kéo; mesh 3D vẫn giữ
  // toạ độ thật nhưng không cần render lại 14-20 FPS mỗi lần ngón tay di chuyển.
  showProxy(group,e);
  group.visible=false;
  group.userData.shadow.visible=false;
  requestRender(); // Chỉ redraw đúng một lần để ẩn mesh gốc.
  metrics.textContent='BÁM TAY · đang kéo';
  // Không gửi callback về Flutter khi chạm, tránh rebuild platform view.
}
function updatePointer(e){
  if(!active||active.id!==e.pointerId)return;
  e.preventDefault();
  // QUAN TRỌNG: cập nhật DOM ngay trong event, KHÔNG rAF, KHÔNG lerp.
  setProxyAt(e.clientX,e.clientY);
  const p=surfacePoint(e);
  if(p){
    const x=Math.max(-5.14,Math.min(5.14,p.x+active.offsetX));
    const z=Math.max(-2.25,Math.min(2.25,p.z+active.offsetZ));
    active.group.position.x=x;active.group.position.z=z;
    active.group.userData.shadow.position.set(x,.285,z);
  }
  const now=performance.now();
  active.history.push({x:e.clientX,t:now});
  while(active.history.length>2 && now-active.history[0].t>130)active.history.shift();
  const dx=e.clientX-active.startX;
  if(Math.abs(dx)>28)hints(dx<0?'left':'right',Math.abs(dx)>80);
  else hints(null,false);
  // Không gọi renderer.render hoặc requestRender tại đây: GPU máy ảo rất chậm.
}
function pointerMove(e){
  // pointerrawupdate có thể nhanh hơn pointermove trên Chromium Android;
  // lắng nghe cả hai để hoạt động trên WebView không hỗ trợ rawupdate.
  updatePointer(e);
}
function removeFruit(group){
  const index=fruits.indexOf(group);
  if(index>=0)fruits.splice(index,1);
  bodies.splice(bodies.indexOf(group.children[0]),1);
  scene.remove(group);scene.remove(group.userData.shadow);
  tell('count',{count:fruits.length});
  requestRender();
}
function pointerUp(e){
  if(!active||active.id!==e.pointerId)return;
  updatePointer(e); // bảo đảm nhận vị trí CUỐI CÙNG kể cả khi bỏ lỡ pointermove
  const {group,startX,history}=active;
  const elapsed=Math.max(30,performance.now()-history[0].t);
  const velocity=(e.clientX-history[0].x)/elapsed;
  const dx=e.clientX-startX;
  const nearEdge=Math.abs(group.position.x)>4.65;
  const throwIt=(e.type!=='pointercancel')&&
    ((Math.abs(dx)>65&&Math.abs(velocity)>.62)||(nearEdge&&Math.abs(dx)>38));
  const direction=dx<0?'left':'right';
  if(throwIt){
    removeFruit(group);
    tell('swipe',{direction});
  } else {
    group.position.y=.78;
    group.visible=true;
    group.userData.shadow.visible=true;
    tell('moved');
  }
  active=null;
  isDragging=false;
  canvas.classList.remove('drag');
  hints(null,false);
  // Giữ hình theo ngón tay tới khi khung 3D mới hoàn thành, tránh hình biến mất.
  requestRender(()=>{dragProxy.style.display='none';});
  metrics.textContent=`THREE.JS · nghỉ · ${fruits.length} vật thể`;
}
canvas.addEventListener('pointerdown',pointerDown,{passive:false});
canvas.addEventListener('pointermove',pointerMove,{passive:false});
if('onpointerrawupdate' in window) canvas.addEventListener('pointerrawupdate',(e)=>{if(active&&active.id===e.pointerId)setProxyAt(e.clientX,e.clientY);},{passive:true});
canvas.addEventListener('pointerup',pointerUp,{passive:false});
canvas.addEventListener('pointercancel',pointerUp,{passive:false});
window.game3D={
  spawnOrange(){
    const n=fruits.length;
    const x=Math.max(-4.6,Math.min(4.6, ((n%5)-2)*1.32));
    const z=-.65+(Math.floor(n/5)%3)*1.1;
    createFruit(x,z);tell('count',{count:fruits.length});requestRender();
  },
  clear(){
    for(const fruit of [...fruits])removeFruit(fruit);
    active=null;isDragging=false;hints(null,false);
    dragProxy.style.display='none';
    tell('count',{count:0});requestRender();
  }
};
resize();requestRender();
metrics.textContent='THREE.JS · chế độ bám tay';
tell('ready');
})().catch((error)=>{
  document.getElementById('error').style.display='block';
  document.getElementById('error').textContent=String(error);
  try{window.Game3D?.postMessage(JSON.stringify({type:'error',message:String(error)}));}catch(_){}
});
</script>
</body></html>
''';
