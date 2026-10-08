(()=>{var Hh=0,Rc=1,Wh=2;var _r=1,Xh=2,Ts=3,On=0,Gt=1,hn=2,Un=0,Es=1,Cc=2,zc=3,Ic=4,qh=5;var Ui=100,Yh=101,Zh=102,Kh=103,Jh=104,$h=200,jh=201,Qh=202,eu=203,Pc=204,Lc=205,tu=206,nu=207,iu=208,su=209,ru=210,au=211,ou=212,cu=213,lu=214,ha=0,ua=1,fa=2,cs=3,da=4,pa=5,ma=6,Ma=7,Da=0,hu=1,uu=2,vn=0,Nc=1,Dc=2,Oc=3,Uc=4,Fc=5,Bc=6,kc=7,Mc="attached",fu="detached",Vc=300,gi=301,Fi=302,Oa=303,Ua=304,xr=306,di=1e3,cn=1001,ls=1002,dt=1003,Fa=1004;var Bi=1005;var pt=1006,As=1007;var bn=1008;var Zt=1009,Gc=1010,Hc=1011,Rs=1012,Ba=1013,Sn=1014,nn=1015,wn=1016,ka=1017,Va=1018,Cs=1020,Wc=35902,Xc=35899,qc=1021,Yc=1022,sn=1023,In=1026,_i=1027,Ga=1028,Ha=1029,xi=1030,Wa=1031;var Xa=1033,yr=33776,vr=33777,br=33778,Sr=33779,qa=35840,Ya=35841,Za=35842,Ka=35843,Ja=36196,$a=37492,ja=37496,Qa=37488,eo=37489,wr=37490,to=37491,no=37808,io=37809,so=37810,ro=37811,ao=37812,oo=37813,co=37814,lo=37815,ho=37816,uo=37817,fo=37818,po=37819,mo=37820,Mo=37821,go=36492,_o=36494,xo=36495,yo=36283,vo=36284,Tr=36285,bo=36286;var Ci=2300,zi=2301,oa=2302,gc=2303,_c=2400,xc=2401,yc=2402,du=2500;var Zc=0,Er=1,zs=2,pu=3200;var Ar=0,mu=1,ei="",vt="srgb",kt="srgb-linear",Zs="linear",$e="srgb";var ca=7680;var Mu=519,gu=512,_u=513,xu=514,So=515,yu=516,vu=517,wo=518,bu=519,Kc=35044;var Jc="300 es",_n=2e3,hs=2001;function Cf(i){for(let e=i.length-1;e>=0;--e)if(i[e]>=65535)return!0;return!1}function zf(i){return ArrayBuffer.isView(i)&&!(i instanceof DataView)}function us(i){return document.createElementNS("http://www.w3.org/1999/xhtml",i)}function Su(){let i=us("canvas");return i.style.display="block",i}var ah={},fs=null;function Ks(...i){let e="THREE."+i.shift();fs?fs("log",e,...i):console.log(e,...i)}function wu(i){let e=i[0];if(typeof e=="string"&&e.startsWith("TSL:")){let t=i[1];t&&t.isStackTrace?i[0]+=" "+t.getLocation():i[1]='Stack trace not available. Enable "THREE.Node.captureStackTrace" to capture stack traces.'}return i}function be(...i){i=wu(i);let e="THREE."+i.shift();if(fs)fs("warn",e,...i);else{let t=i[0];t&&t.isStackTrace?console.warn(t.getError(e)):console.warn(e,...i)}}function ze(...i){i=wu(i);let e="THREE."+i.shift();if(fs)fs("error",e,...i);else{let t=i[0];t&&t.isStackTrace?console.error(t.getError(e)):console.error(e,...i)}}function Ri(...i){let e=i.join(" ");e in ah||(ah[e]=!0,be(...i))}function Tu(i,e,t){return new Promise(function(n,s){function r(){switch(i.clientWaitSync(e,i.SYNC_FLUSH_COMMANDS_BIT,0)){case i.WAIT_FAILED:s();break;case i.TIMEOUT_EXPIRED:setTimeout(r,t);break;default:n()}}setTimeout(r,t)})}var Eu={[ha]:ua,[fa]:ma,[da]:Ma,[cs]:pa,[ua]:ha,[ma]:fa,[Ma]:da,[pa]:cs},Pn=class{addEventListener(e,t){this._listeners===void 0&&(this._listeners={});let n=this._listeners;n[e]===void 0&&(n[e]=[]),n[e].indexOf(t)===-1&&n[e].push(t)}hasEventListener(e,t){let n=this._listeners;return n===void 0?!1:n[e]!==void 0&&n[e].indexOf(t)!==-1}removeEventListener(e,t){let n=this._listeners;if(n===void 0)return;let s=n[e];if(s!==void 0){let r=s.indexOf(t);r!==-1&&s.splice(r,1)}}dispatchEvent(e){let t=this._listeners;if(t===void 0)return;let n=t[e.type];if(n!==void 0){e.target=this;let s=n.slice(0);for(let r=0,a=s.length;r<a;r++)s[r].call(this,e);e.target=null}}},Pt=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"],oh=1234567,qs=Math.PI/180,Ii=180/Math.PI;function xn(){let i=Math.random()*4294967295|0,e=Math.random()*4294967295|0,t=Math.random()*4294967295|0,n=Math.random()*4294967295|0;return(Pt[i&255]+Pt[i>>8&255]+Pt[i>>16&255]+Pt[i>>24&255]+"-"+Pt[e&255]+Pt[e>>8&255]+"-"+Pt[e>>16&15|64]+Pt[e>>24&255]+"-"+Pt[t&63|128]+Pt[t>>8&255]+"-"+Pt[t>>16&255]+Pt[t>>24&255]+Pt[n&255]+Pt[n>>8&255]+Pt[n>>16&255]+Pt[n>>24&255]).toLowerCase()}function He(i,e,t){return Math.max(e,Math.min(t,i))}function $c(i,e){return(i%e+e)%e}function If(i,e,t,n,s){return n+(i-e)*(s-n)/(t-e)}function Pf(i,e,t){return i!==e?(t-i)/(e-i):0}function Ys(i,e,t){return(1-t)*i+t*e}function Lf(i,e,t,n){return Ys(i,e,1-Math.exp(-t*n))}function Nf(i,e=1){return e-Math.abs($c(i,e*2)-e)}function Df(i,e,t){return i<=e?0:i>=t?1:(i=(i-e)/(t-e),i*i*(3-2*i))}function Of(i,e,t){return i<=e?0:i>=t?1:(i=(i-e)/(t-e),i*i*i*(i*(i*6-15)+10))}function Uf(i,e){return i+Math.floor(Math.random()*(e-i+1))}function Ff(i,e){return i+Math.random()*(e-i)}function Bf(i){return i*(.5-Math.random())}function kf(i){i!==void 0&&(oh=i);let e=oh+=1831565813;return e=Math.imul(e^e>>>15,e|1),e^=e+Math.imul(e^e>>>7,e|61),((e^e>>>14)>>>0)/4294967296}function Vf(i){return i*qs}function Gf(i){return i*Ii}function Hf(i){return i>0&&Number.isInteger(i)&&2**Math.round(Math.log2(i))===i}function Wf(i){return Math.pow(2,Math.ceil(Math.log(i)/Math.LN2))}function Xf(i){return Math.pow(2,Math.floor(Math.log(i)/Math.LN2))}function qf(i,e,t,n,s){let r=Math.cos,a=Math.sin,o=r(t/2),c=a(t/2),l=r((e+n)/2),h=a((e+n)/2),f=r((e-n)/2),u=a((e-n)/2),d=r((n-e)/2),g=a((n-e)/2);switch(s){case"XYX":i.set(o*h,c*f,c*u,o*l);break;case"YZY":i.set(c*u,o*h,c*f,o*l);break;case"ZXZ":i.set(c*f,c*u,o*h,o*l);break;case"XZX":i.set(o*h,c*g,c*d,o*l);break;case"YXY":i.set(c*d,o*h,c*g,o*l);break;case"ZYZ":i.set(c*g,c*d,o*h,o*l);break;default:be("MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: "+s)}}function gn(i,e){switch(e.constructor){case Float32Array:return i;case Uint32Array:return i/4294967295;case Uint16Array:return i/65535;case Uint8Array:case Uint8ClampedArray:return i/255;case Int32Array:return Math.max(i/2147483647,-1);case Int16Array:return Math.max(i/32767,-1);case Int8Array:return Math.max(i/127,-1);default:throw new Error("THREE.MathUtils: Invalid component type.")}}function Qe(i,e){switch(e.constructor){case Float32Array:return i;case Uint32Array:return Math.round(i*4294967295);case Uint16Array:return Math.round(i*65535);case Uint8Array:case Uint8ClampedArray:return Math.round(i*255);case Int32Array:return Math.round(i*2147483647);case Int16Array:return Math.round(i*32767);case Int8Array:return Math.round(i*127);default:throw new Error("THREE.MathUtils: Invalid component type.")}}var yi={DEG2RAD:qs,RAD2DEG:Ii,generateUUID:xn,clamp:He,euclideanModulo:$c,mapLinear:If,inverseLerp:Pf,lerp:Ys,damp:Lf,pingpong:Nf,smoothstep:Df,smootherstep:Of,randInt:Uf,randFloat:Ff,randFloatSpread:Bf,seededRandom:kf,degToRad:Vf,radToDeg:Gf,isPowerOfTwo:Hf,ceilPowerOfTwo:Wf,floorPowerOfTwo:Xf,setQuaternionFromProperEuler:qf,normalize:Qe,denormalize:gn},Oe=class i{static{i.prototype.isVector2=!0}constructor(e=0,t=0){this.x=e,this.y=t}get width(){return this.x}set width(e){this.x=e}get height(){return this.y}set height(e){this.y=e}set(e,t){return this.x=e,this.y=t,this}setScalar(e){return this.x=e,this.y=e,this}setX(e){return this.x=e,this}setY(e){return this.y=e,this}setComponent(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;default:throw new Error("THREE.Vector2: index is out of range: "+e)}return this}getComponent(e){switch(e){case 0:return this.x;case 1:return this.y;default:throw new Error("THREE.Vector2: index is out of range: "+e)}}clone(){return new this.constructor(this.x,this.y)}copy(e){return this.x=e.x,this.y=e.y,this}add(e){return this.x+=e.x,this.y+=e.y,this}addScalar(e){return this.x+=e,this.y+=e,this}addVectors(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this}addScaledVector(e,t){return this.x+=e.x*t,this.y+=e.y*t,this}sub(e){return this.x-=e.x,this.y-=e.y,this}subScalar(e){return this.x-=e,this.y-=e,this}subVectors(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this}multiply(e){return this.x*=e.x,this.y*=e.y,this}multiplyScalar(e){return this.x*=e,this.y*=e,this}divide(e){return this.x/=e.x,this.y/=e.y,this}divideScalar(e){return this.multiplyScalar(1/e)}applyMatrix3(e){let t=this.x,n=this.y,s=e.elements;return this.x=s[0]*t+s[3]*n+s[6],this.y=s[1]*t+s[4]*n+s[7],this}min(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this}max(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this}clamp(e,t){return this.x=He(this.x,e.x,t.x),this.y=He(this.y,e.y,t.y),this}clampScalar(e,t){return this.x=He(this.x,e,t),this.y=He(this.y,e,t),this}clampLength(e,t){let n=this.length();return this.divideScalar(n||1).multiplyScalar(He(n,e,t))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(e){return this.x*e.x+this.y*e.y}cross(e){return this.x*e.y-this.y*e.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(e){let t=Math.sqrt(this.lengthSq()*e.lengthSq());if(t===0)return Math.PI/2;let n=this.dot(e)/t;return Math.acos(He(n,-1,1))}distanceTo(e){return Math.sqrt(this.distanceToSquared(e))}distanceToSquared(e){let t=this.x-e.x,n=this.y-e.y;return t*t+n*n}manhattanDistanceTo(e){return Math.abs(this.x-e.x)+Math.abs(this.y-e.y)}setLength(e){return this.normalize().multiplyScalar(e)}lerp(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this}lerpVectors(e,t,n){return this.x=e.x+(t.x-e.x)*n,this.y=e.y+(t.y-e.y)*n,this}equals(e){return e.x===this.x&&e.y===this.y}fromArray(e,t=0){return this.x=e[t],this.y=e[t+1],this}toArray(e=[],t=0){return e[t]=this.x,e[t+1]=this.y,e}fromBufferAttribute(e,t){return this.x=e.getX(t),this.y=e.getY(t),this}rotateAround(e,t){let n=Math.cos(t),s=Math.sin(t),r=this.x-e.x,a=this.y-e.y;return this.x=r*n-a*s+e.x,this.y=r*s+a*n+e.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}},Qt=class{constructor(e=0,t=0,n=0,s=1){this.isQuaternion=!0,this._x=e,this._y=t,this._z=n,this._w=s}static slerpFlat(e,t,n,s,r,a,o){let c=n[s+0],l=n[s+1],h=n[s+2],f=n[s+3],u=r[a+0],d=r[a+1],g=r[a+2],y=r[a+3];if(f!==y||c!==u||l!==d||h!==g){let m=c*u+l*d+h*g+f*y;m<0&&(u=-u,d=-d,g=-g,y=-y,m=-m);let p=1-o;if(m<.9995){let T=Math.acos(m),R=Math.sin(T);p=Math.sin(p*T)/R,o=Math.sin(o*T)/R,c=c*p+u*o,l=l*p+d*o,h=h*p+g*o,f=f*p+y*o}else{c=c*p+u*o,l=l*p+d*o,h=h*p+g*o,f=f*p+y*o;let T=1/Math.sqrt(c*c+l*l+h*h+f*f);c*=T,l*=T,h*=T,f*=T}}e[t]=c,e[t+1]=l,e[t+2]=h,e[t+3]=f}static multiplyQuaternionsFlat(e,t,n,s,r,a){let o=n[s],c=n[s+1],l=n[s+2],h=n[s+3],f=r[a],u=r[a+1],d=r[a+2],g=r[a+3];return e[t]=o*g+h*f+c*d-l*u,e[t+1]=c*g+h*u+l*f-o*d,e[t+2]=l*g+h*d+o*u-c*f,e[t+3]=h*g-o*f-c*u-l*d,e}get x(){return this._x}set x(e){this._x=e,this._onChangeCallback()}get y(){return this._y}set y(e){this._y=e,this._onChangeCallback()}get z(){return this._z}set z(e){this._z=e,this._onChangeCallback()}get w(){return this._w}set w(e){this._w=e,this._onChangeCallback()}set(e,t,n,s){return this._x=e,this._y=t,this._z=n,this._w=s,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(e){return this._x=e.x,this._y=e.y,this._z=e.z,this._w=e.w,this._onChangeCallback(),this}setFromEuler(e,t=!0){let n=e._x,s=e._y,r=e._z,a=e._order,o=Math.cos,c=Math.sin,l=o(n/2),h=o(s/2),f=o(r/2),u=c(n/2),d=c(s/2),g=c(r/2);switch(a){case"XYZ":this._x=u*h*f+l*d*g,this._y=l*d*f-u*h*g,this._z=l*h*g+u*d*f,this._w=l*h*f-u*d*g;break;case"YXZ":this._x=u*h*f+l*d*g,this._y=l*d*f-u*h*g,this._z=l*h*g-u*d*f,this._w=l*h*f+u*d*g;break;case"ZXY":this._x=u*h*f-l*d*g,this._y=l*d*f+u*h*g,this._z=l*h*g+u*d*f,this._w=l*h*f-u*d*g;break;case"ZYX":this._x=u*h*f-l*d*g,this._y=l*d*f+u*h*g,this._z=l*h*g-u*d*f,this._w=l*h*f+u*d*g;break;case"YZX":this._x=u*h*f+l*d*g,this._y=l*d*f+u*h*g,this._z=l*h*g-u*d*f,this._w=l*h*f-u*d*g;break;case"XZY":this._x=u*h*f-l*d*g,this._y=l*d*f-u*h*g,this._z=l*h*g+u*d*f,this._w=l*h*f+u*d*g;break;default:be("Quaternion: .setFromEuler() encountered an unknown order: "+a)}return t===!0&&this._onChangeCallback(),this}setFromAxisAngle(e,t){let n=t/2,s=Math.sin(n);return this._x=e.x*s,this._y=e.y*s,this._z=e.z*s,this._w=Math.cos(n),this._onChangeCallback(),this}setFromRotationMatrix(e){let t=e.elements,n=t[0],s=t[4],r=t[8],a=t[1],o=t[5],c=t[9],l=t[2],h=t[6],f=t[10],u=n+o+f;if(u>0){let d=.5/Math.sqrt(u+1);this._w=.25/d,this._x=(h-c)*d,this._y=(r-l)*d,this._z=(a-s)*d}else if(n>o&&n>f){let d=2*Math.sqrt(1+n-o-f);this._w=(h-c)/d,this._x=.25*d,this._y=(s+a)/d,this._z=(r+l)/d}else if(o>f){let d=2*Math.sqrt(1+o-n-f);this._w=(r-l)/d,this._x=(s+a)/d,this._y=.25*d,this._z=(c+h)/d}else{let d=2*Math.sqrt(1+f-n-o);this._w=(a-s)/d,this._x=(r+l)/d,this._y=(c+h)/d,this._z=.25*d}return this._onChangeCallback(),this}setFromUnitVectors(e,t){let n=e.dot(t)+1;return n<1e-8?(n=0,Math.abs(e.x)>Math.abs(e.z)?(this._x=-e.y,this._y=e.x,this._z=0,this._w=n):(this._x=0,this._y=-e.z,this._z=e.y,this._w=n)):(this._x=e.y*t.z-e.z*t.y,this._y=e.z*t.x-e.x*t.z,this._z=e.x*t.y-e.y*t.x,this._w=n),this.normalize()}angleTo(e){return 2*Math.acos(Math.abs(He(this.dot(e),-1,1)))}rotateTowards(e,t){let n=this.angleTo(e);if(n===0)return this;let s=Math.min(1,t/n);return this.slerp(e,s),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(e){return this._x*e._x+this._y*e._y+this._z*e._z+this._w*e._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let e=this.length();return e===0?(this._x=0,this._y=0,this._z=0,this._w=1):(e=1/e,this._x=this._x*e,this._y=this._y*e,this._z=this._z*e,this._w=this._w*e),this._onChangeCallback(),this}multiply(e){return this.multiplyQuaternions(this,e)}premultiply(e){return this.multiplyQuaternions(e,this)}multiplyQuaternions(e,t){let n=e._x,s=e._y,r=e._z,a=e._w,o=t._x,c=t._y,l=t._z,h=t._w;return this._x=n*h+a*o+s*l-r*c,this._y=s*h+a*c+r*o-n*l,this._z=r*h+a*l+n*c-s*o,this._w=a*h-n*o-s*c-r*l,this._onChangeCallback(),this}slerp(e,t){let n=e._x,s=e._y,r=e._z,a=e._w,o=this.dot(e);o<0&&(n=-n,s=-s,r=-r,a=-a,o=-o);let c=1-t;if(o<.9995){let l=Math.acos(o),h=Math.sin(l);c=Math.sin(c*l)/h,t=Math.sin(t*l)/h,this._x=this._x*c+n*t,this._y=this._y*c+s*t,this._z=this._z*c+r*t,this._w=this._w*c+a*t,this._onChangeCallback()}else this._x=this._x*c+n*t,this._y=this._y*c+s*t,this._z=this._z*c+r*t,this._w=this._w*c+a*t,this.normalize();return this}slerpQuaternions(e,t,n){return this.copy(e).slerp(t,n)}random(){let e=2*Math.PI*Math.random(),t=2*Math.PI*Math.random(),n=Math.random(),s=Math.sqrt(1-n),r=Math.sqrt(n);return this.set(s*Math.sin(e),s*Math.cos(e),r*Math.sin(t),r*Math.cos(t))}equals(e){return e._x===this._x&&e._y===this._y&&e._z===this._z&&e._w===this._w}fromArray(e,t=0){return this._x=e[t],this._y=e[t+1],this._z=e[t+2],this._w=e[t+3],this._onChangeCallback(),this}toArray(e=[],t=0){return e[t]=this._x,e[t+1]=this._y,e[t+2]=this._z,e[t+3]=this._w,e}fromBufferAttribute(e,t){return this._x=e.getX(t),this._y=e.getY(t),this._z=e.getZ(t),this._w=e.getW(t),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(e){return this._onChangeCallback=e,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}},O=class i{static{i.prototype.isVector3=!0}constructor(e=0,t=0,n=0){this.x=e,this.y=t,this.z=n}set(e,t,n){return n===void 0&&(n=this.z),this.x=e,this.y=t,this.z=n,this}setScalar(e){return this.x=e,this.y=e,this.z=e,this}setX(e){return this.x=e,this}setY(e){return this.y=e,this}setZ(e){return this.z=e,this}setComponent(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;case 2:this.z=t;break;default:throw new Error("THREE.Vector3: index is out of range: "+e)}return this}getComponent(e){switch(e){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("THREE.Vector3: index is out of range: "+e)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(e){return this.x=e.x,this.y=e.y,this.z=e.z,this}add(e){return this.x+=e.x,this.y+=e.y,this.z+=e.z,this}addScalar(e){return this.x+=e,this.y+=e,this.z+=e,this}addVectors(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this.z=e.z+t.z,this}addScaledVector(e,t){return this.x+=e.x*t,this.y+=e.y*t,this.z+=e.z*t,this}sub(e){return this.x-=e.x,this.y-=e.y,this.z-=e.z,this}subScalar(e){return this.x-=e,this.y-=e,this.z-=e,this}subVectors(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this.z=e.z-t.z,this}multiply(e){return this.x*=e.x,this.y*=e.y,this.z*=e.z,this}multiplyScalar(e){return this.x*=e,this.y*=e,this.z*=e,this}multiplyVectors(e,t){return this.x=e.x*t.x,this.y=e.y*t.y,this.z=e.z*t.z,this}applyEuler(e){return this.applyQuaternion(ch.setFromEuler(e))}applyAxisAngle(e,t){return this.applyQuaternion(ch.setFromAxisAngle(e,t))}applyMatrix3(e){let t=this.x,n=this.y,s=this.z,r=e.elements;return this.x=r[0]*t+r[3]*n+r[6]*s,this.y=r[1]*t+r[4]*n+r[7]*s,this.z=r[2]*t+r[5]*n+r[8]*s,this}applyNormalMatrix(e){return this.applyMatrix3(e).normalize()}applyMatrix4(e){let t=this.x,n=this.y,s=this.z,r=e.elements,a=1/(r[3]*t+r[7]*n+r[11]*s+r[15]);return this.x=(r[0]*t+r[4]*n+r[8]*s+r[12])*a,this.y=(r[1]*t+r[5]*n+r[9]*s+r[13])*a,this.z=(r[2]*t+r[6]*n+r[10]*s+r[14])*a,this}applyQuaternion(e){let t=this.x,n=this.y,s=this.z,r=e.x,a=e.y,o=e.z,c=e.w,l=2*(a*s-o*n),h=2*(o*t-r*s),f=2*(r*n-a*t);return this.x=t+c*l+a*f-o*h,this.y=n+c*h+o*l-r*f,this.z=s+c*f+r*h-a*l,this}project(e){return this.applyMatrix4(e.matrixWorldInverse).applyMatrix4(e.projectionMatrix)}unproject(e){return this.applyMatrix4(e.projectionMatrixInverse).applyMatrix4(e.matrixWorld)}transformDirection(e){let t=this.x,n=this.y,s=this.z,r=e.elements;return this.x=r[0]*t+r[4]*n+r[8]*s,this.y=r[1]*t+r[5]*n+r[9]*s,this.z=r[2]*t+r[6]*n+r[10]*s,this.normalize()}divide(e){return this.x/=e.x,this.y/=e.y,this.z/=e.z,this}divideScalar(e){return this.multiplyScalar(1/e)}min(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this.z=Math.min(this.z,e.z),this}max(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this.z=Math.max(this.z,e.z),this}clamp(e,t){return this.x=He(this.x,e.x,t.x),this.y=He(this.y,e.y,t.y),this.z=He(this.z,e.z,t.z),this}clampScalar(e,t){return this.x=He(this.x,e,t),this.y=He(this.y,e,t),this.z=He(this.z,e,t),this}clampLength(e,t){let n=this.length();return this.divideScalar(n||1).multiplyScalar(He(n,e,t))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(e){return this.x*e.x+this.y*e.y+this.z*e.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(e){return this.normalize().multiplyScalar(e)}lerp(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this.z+=(e.z-this.z)*t,this}lerpVectors(e,t,n){return this.x=e.x+(t.x-e.x)*n,this.y=e.y+(t.y-e.y)*n,this.z=e.z+(t.z-e.z)*n,this}cross(e){return this.crossVectors(this,e)}crossVectors(e,t){let n=e.x,s=e.y,r=e.z,a=t.x,o=t.y,c=t.z;return this.x=s*c-r*o,this.y=r*a-n*c,this.z=n*o-s*a,this}projectOnVector(e){let t=e.lengthSq();if(t===0)return this.set(0,0,0);let n=e.dot(this)/t;return this.copy(e).multiplyScalar(n)}projectOnPlane(e){return qo.copy(this).projectOnVector(e),this.sub(qo)}reflect(e){return this.sub(qo.copy(e).multiplyScalar(2*this.dot(e)))}angleTo(e){let t=Math.sqrt(this.lengthSq()*e.lengthSq());if(t===0)return Math.PI/2;let n=this.dot(e)/t;return Math.acos(He(n,-1,1))}distanceTo(e){return Math.sqrt(this.distanceToSquared(e))}distanceToSquared(e){let t=this.x-e.x,n=this.y-e.y,s=this.z-e.z;return t*t+n*n+s*s}manhattanDistanceTo(e){return Math.abs(this.x-e.x)+Math.abs(this.y-e.y)+Math.abs(this.z-e.z)}setFromSpherical(e){return this.setFromSphericalCoords(e.radius,e.phi,e.theta)}setFromSphericalCoords(e,t,n){let s=Math.sin(t)*e;return this.x=s*Math.sin(n),this.y=Math.cos(t)*e,this.z=s*Math.cos(n),this}setFromCylindrical(e){return this.setFromCylindricalCoords(e.radius,e.theta,e.y)}setFromCylindricalCoords(e,t,n){return this.x=e*Math.sin(t),this.y=n,this.z=e*Math.cos(t),this}setFromMatrixPosition(e){let t=e.elements;return this.x=t[12],this.y=t[13],this.z=t[14],this}setFromMatrixScale(e){let t=this.setFromMatrixColumn(e,0).length(),n=this.setFromMatrixColumn(e,1).length(),s=this.setFromMatrixColumn(e,2).length();return this.x=t,this.y=n,this.z=s,this}setFromMatrixColumn(e,t){return this.fromArray(e.elements,t*4)}setFromMatrix3Column(e,t){return this.fromArray(e.elements,t*3)}setFromEuler(e){return this.x=e._x,this.y=e._y,this.z=e._z,this}setFromColor(e){return this.x=e.r,this.y=e.g,this.z=e.b,this}equals(e){return e.x===this.x&&e.y===this.y&&e.z===this.z}fromArray(e,t=0){return this.x=e[t],this.y=e[t+1],this.z=e[t+2],this}toArray(e=[],t=0){return e[t]=this.x,e[t+1]=this.y,e[t+2]=this.z,e}fromBufferAttribute(e,t){return this.x=e.getX(t),this.y=e.getY(t),this.z=e.getZ(t),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){let e=Math.random()*Math.PI*2,t=Math.random()*2-1,n=Math.sqrt(1-t*t);return this.x=n*Math.cos(e),this.y=t,this.z=n*Math.sin(e),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}},qo=new O,ch=new Qt,Ie=class i{static{i.prototype.isMatrix3=!0}constructor(e,t,n,s,r,a,o,c,l){this.elements=[1,0,0,0,1,0,0,0,1],e!==void 0&&this.set(e,t,n,s,r,a,o,c,l)}set(e,t,n,s,r,a,o,c,l){let h=this.elements;return h[0]=e,h[1]=s,h[2]=o,h[3]=t,h[4]=r,h[5]=c,h[6]=n,h[7]=a,h[8]=l,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(e){let t=this.elements,n=e.elements;return t[0]=n[0],t[1]=n[1],t[2]=n[2],t[3]=n[3],t[4]=n[4],t[5]=n[5],t[6]=n[6],t[7]=n[7],t[8]=n[8],this}extractBasis(e,t,n){return e.setFromMatrix3Column(this,0),t.setFromMatrix3Column(this,1),n.setFromMatrix3Column(this,2),this}setFromMatrix4(e){let t=e.elements;return this.set(t[0],t[4],t[8],t[1],t[5],t[9],t[2],t[6],t[10]),this}multiply(e){return this.multiplyMatrices(this,e)}premultiply(e){return this.multiplyMatrices(e,this)}multiplyMatrices(e,t){let n=e.elements,s=t.elements,r=this.elements,a=n[0],o=n[3],c=n[6],l=n[1],h=n[4],f=n[7],u=n[2],d=n[5],g=n[8],y=s[0],m=s[3],p=s[6],T=s[1],R=s[4],v=s[7],b=s[2],S=s[5],A=s[8];return r[0]=a*y+o*T+c*b,r[3]=a*m+o*R+c*S,r[6]=a*p+o*v+c*A,r[1]=l*y+h*T+f*b,r[4]=l*m+h*R+f*S,r[7]=l*p+h*v+f*A,r[2]=u*y+d*T+g*b,r[5]=u*m+d*R+g*S,r[8]=u*p+d*v+g*A,this}multiplyScalar(e){let t=this.elements;return t[0]*=e,t[3]*=e,t[6]*=e,t[1]*=e,t[4]*=e,t[7]*=e,t[2]*=e,t[5]*=e,t[8]*=e,this}determinant(){let e=this.elements,t=e[0],n=e[1],s=e[2],r=e[3],a=e[4],o=e[5],c=e[6],l=e[7],h=e[8];return t*a*h-t*o*l-n*r*h+n*o*c+s*r*l-s*a*c}invert(){let e=this.elements,t=e[0],n=e[1],s=e[2],r=e[3],a=e[4],o=e[5],c=e[6],l=e[7],h=e[8],f=h*a-o*l,u=o*c-h*r,d=l*r-a*c,g=t*f+n*u+s*d;if(g===0)return this.set(0,0,0,0,0,0,0,0,0);let y=1/g;return e[0]=f*y,e[1]=(s*l-h*n)*y,e[2]=(o*n-s*a)*y,e[3]=u*y,e[4]=(h*t-s*c)*y,e[5]=(s*r-o*t)*y,e[6]=d*y,e[7]=(n*c-l*t)*y,e[8]=(a*t-n*r)*y,this}transpose(){let e,t=this.elements;return e=t[1],t[1]=t[3],t[3]=e,e=t[2],t[2]=t[6],t[6]=e,e=t[5],t[5]=t[7],t[7]=e,this}getNormalMatrix(e){return this.setFromMatrix4(e).invert().transpose()}transposeIntoArray(e){let t=this.elements;return e[0]=t[0],e[1]=t[3],e[2]=t[6],e[3]=t[1],e[4]=t[4],e[5]=t[7],e[6]=t[2],e[7]=t[5],e[8]=t[8],this}setUvTransform(e,t,n,s,r,a,o){let c=Math.cos(r),l=Math.sin(r);return this.set(n*c,n*l,-n*(c*a+l*o)+a+e,-s*l,s*c,-s*(-l*a+c*o)+o+t,0,0,1),this}scale(e,t){return Ri("Matrix3: .scale() is deprecated. Use .makeScale() instead."),this.premultiply(Yo.makeScale(e,t)),this}rotate(e){return Ri("Matrix3: .rotate() is deprecated. Use .makeRotation() instead."),this.premultiply(Yo.makeRotation(-e)),this}translate(e,t){return Ri("Matrix3: .translate() is deprecated. Use .makeTranslation() instead."),this.premultiply(Yo.makeTranslation(e,t)),this}makeTranslation(e,t){return e.isVector2?this.set(1,0,e.x,0,1,e.y,0,0,1):this.set(1,0,e,0,1,t,0,0,1),this}makeRotation(e){let t=Math.cos(e),n=Math.sin(e);return this.set(t,-n,0,n,t,0,0,0,1),this}makeScale(e,t){return this.set(e,0,0,0,t,0,0,0,1),this}equals(e){let t=this.elements,n=e.elements;for(let s=0;s<9;s++)if(t[s]!==n[s])return!1;return!0}fromArray(e,t=0){for(let n=0;n<9;n++)this.elements[n]=e[n+t];return this}toArray(e=[],t=0){let n=this.elements;return e[t]=n[0],e[t+1]=n[1],e[t+2]=n[2],e[t+3]=n[3],e[t+4]=n[4],e[t+5]=n[5],e[t+6]=n[6],e[t+7]=n[7],e[t+8]=n[8],e}clone(){return new this.constructor().fromArray(this.elements)}},Yo=new Ie,lh=new Ie().set(.4123908,.3575843,.1804808,.212639,.7151687,.0721923,.0193308,.1191948,.9505322),hh=new Ie().set(3.2409699,-1.5373832,-.4986108,-.9692436,1.8759675,.0415551,.0556301,-.203977,1.0569715);function Yf(){let i={enabled:!0,workingColorSpace:kt,spaces:{},convert:function(s,r,a){return this.enabled===!1||r===a||!r||!a||(this.spaces[r].transfer===$e&&(s.r=Yn(s.r),s.g=Yn(s.g),s.b=Yn(s.b)),this.spaces[r].primaries!==this.spaces[a].primaries&&(s.applyMatrix3(this.spaces[r].toXYZ),s.applyMatrix3(this.spaces[a].fromXYZ)),this.spaces[a].transfer===$e&&(s.r=os(s.r),s.g=os(s.g),s.b=os(s.b))),s},workingToColorSpace:function(s,r){return this.convert(s,this.workingColorSpace,r)},colorSpaceToWorking:function(s,r){return this.convert(s,r,this.workingColorSpace)},getPrimaries:function(s){return this.spaces[s].primaries},getTransfer:function(s){return s===ei?Zs:this.spaces[s].transfer},getToneMappingMode:function(s){return this.spaces[s].outputColorSpaceConfig.toneMappingMode||"standard"},getLuminanceCoefficients:function(s,r=this.workingColorSpace){return s.fromArray(this.spaces[r].luminanceCoefficients)},define:function(s){Object.assign(this.spaces,s)},_getMatrix:function(s,r,a){return s.copy(this.spaces[r].toXYZ).multiply(this.spaces[a].fromXYZ)},_getDrawingBufferColorSpace:function(s){return this.spaces[s].outputColorSpaceConfig.drawingBufferColorSpace},_getUnpackColorSpace:function(s=this.workingColorSpace){return this.spaces[s].workingColorSpaceConfig.unpackColorSpace},fromWorkingColorSpace:function(s,r){return Ri("ColorManagement: .fromWorkingColorSpace() has been renamed to .workingToColorSpace()."),i.workingToColorSpace(s,r)},toWorkingColorSpace:function(s,r){return Ri("ColorManagement: .toWorkingColorSpace() has been renamed to .colorSpaceToWorking()."),i.colorSpaceToWorking(s,r)}},e=[.64,.33,.3,.6,.15,.06],t=[.2126,.7152,.0722],n=[.3127,.329];return i.define({[kt]:{primaries:e,whitePoint:n,transfer:Zs,toXYZ:lh,fromXYZ:hh,luminanceCoefficients:t,workingColorSpaceConfig:{unpackColorSpace:vt},outputColorSpaceConfig:{drawingBufferColorSpace:vt}},[vt]:{primaries:e,whitePoint:n,transfer:$e,toXYZ:lh,fromXYZ:hh,luminanceCoefficients:t,outputColorSpaceConfig:{drawingBufferColorSpace:vt}}}),i}var Fe=Yf();function Yn(i){return i<.04045?i*.0773993808:Math.pow(i*.9478672986+.0521327014,2.4)}function os(i){return i<.0031308?i*12.92:1.055*Math.pow(i,.41666)-.055}var Yi,ga=class{static getDataURL(e,t="image/png"){if(/^data:/i.test(e.src)||typeof HTMLCanvasElement>"u")return e.src;let n;if(e instanceof HTMLCanvasElement)n=e;else{Yi===void 0&&(Yi=us("canvas")),Yi.width=e.width,Yi.height=e.height;let s=Yi.getContext("2d");e instanceof ImageData?s.putImageData(e,0,0):s.drawImage(e,0,0,e.width,e.height),n=Yi}return n.toDataURL(t)}static sRGBToLinear(e){if(typeof HTMLImageElement<"u"&&e instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&e instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&e instanceof ImageBitmap){let t=us("canvas");t.width=e.width,t.height=e.height;let n=t.getContext("2d");n.drawImage(e,0,0,e.width,e.height);let s=n.getImageData(0,0,e.width,e.height),r=s.data;for(let a=0;a<r.length;a++)r[a]=Yn(r[a]/255)*255;return n.putImageData(s,0,0),t}else if(e.data){let t=e.data.slice(0);for(let n=0;n<t.length;n++)t instanceof Uint8Array||t instanceof Uint8ClampedArray?t[n]=Math.floor(Yn(t[n]/255)*255):t[n]=Yn(t[n]);return{data:t,width:e.width,height:e.height}}else return be("ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),e}},Zf=0,ds=class{constructor(e=null){this.isTextureSource=!0,Object.defineProperty(this,"id",{value:Zf++}),this.uuid=xn(),this.data=e,this.dataReady=!0,this.version=0}getSize(e){let t=this.data;return typeof HTMLVideoElement<"u"&&t instanceof HTMLVideoElement?e.set(t.videoWidth,t.videoHeight,0):typeof VideoFrame<"u"&&t instanceof VideoFrame?e.set(t.displayWidth,t.displayHeight,0):t!==null?e.set(t.width,t.height,t.depth||0):e.set(0,0,0),e}set needsUpdate(e){e===!0&&this.version++}toJSON(e){let t=e===void 0||typeof e=="string";if(!t&&e.images[this.uuid]!==void 0)return e.images[this.uuid];let n={uuid:this.uuid,url:""},s=this.data;if(s!==null){let r;if(Array.isArray(s)){r=[];for(let a=0,o=s.length;a<o;a++)s[a].isDataTexture?r.push(Zo(s[a].image)):r.push(Zo(s[a]))}else r=Zo(s);n.url=r}return t||(e.images[this.uuid]=n),n}};function Zo(i){return typeof HTMLImageElement<"u"&&i instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&i instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&i instanceof ImageBitmap?ga.getDataURL(i):i.data?{data:Array.from(i.data),width:i.width,height:i.height,type:i.data.constructor.name}:(be("Texture: Unable to serialize Texture."),{})}var Kf=0,Ko=new O,Rt=class i extends Pn{constructor(e=i.DEFAULT_IMAGE,t=i.DEFAULT_MAPPING,n=cn,s=cn,r=pt,a=bn,o=sn,c=Zt,l=i.DEFAULT_ANISOTROPY,h=ei){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:Kf++}),this.uuid=xn(),this.name="",this.source=new ds(e),this.mipmaps=[],this.mapping=t,this.channel=0,this.wrapS=n,this.wrapT=s,this.magFilter=r,this.minFilter=a,this.anisotropy=l,this.format=o,this.internalFormat=null,this.type=c,this.offset=new Oe(0,0),this.repeat=new Oe(1,1),this.center=new Oe(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new Ie,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,this.colorSpace=h,this.userData={},this.updateRanges=[],this.version=0,this.onUpdate=null,this.renderTarget=null,this.isRenderTargetTexture=!1,this.isArrayTexture=!!(e&&e.depth&&e.depth>1),this.pmremVersion=0,this.normalized=!1}get width(){return this.source.getSize(Ko).x}get height(){return this.source.getSize(Ko).y}get depth(){return this.source.getSize(Ko).z}get image(){return this.source.data}set image(e){this.source.data=e}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}addUpdateRange(e,t){this.updateRanges.push({start:e,count:t})}clearUpdateRanges(){this.updateRanges.length=0}clone(){return new this.constructor().copy(this)}copy(e){return this.name=e.name,this.source=e.source,this.mipmaps=e.mipmaps.slice(0),this.mapping=e.mapping,this.channel=e.channel,this.wrapS=e.wrapS,this.wrapT=e.wrapT,this.magFilter=e.magFilter,this.minFilter=e.minFilter,this.anisotropy=e.anisotropy,this.format=e.format,this.internalFormat=e.internalFormat,this.type=e.type,this.normalized=e.normalized,this.offset.copy(e.offset),this.repeat.copy(e.repeat),this.center.copy(e.center),this.rotation=e.rotation,this.matrixAutoUpdate=e.matrixAutoUpdate,this.matrix.copy(e.matrix),this.generateMipmaps=e.generateMipmaps,this.premultiplyAlpha=e.premultiplyAlpha,this.flipY=e.flipY,this.unpackAlignment=e.unpackAlignment,this.colorSpace=e.colorSpace,this.renderTarget=e.renderTarget,this.isRenderTargetTexture=e.isRenderTargetTexture,this.isArrayTexture=e.isArrayTexture,this.userData=JSON.parse(JSON.stringify(e.userData)),this.needsUpdate=!0,this}setValues(e){for(let t in e){let n=e[t];if(n===void 0){be(`Texture.setValues(): parameter '${t}' has value of undefined.`);continue}let s=this[t];if(s===void 0){be(`Texture.setValues(): property '${t}' does not exist.`);continue}s&&n&&s.isVector2&&n.isVector2||s&&n&&s.isVector3&&n.isVector3||s&&n&&s.isMatrix3&&n.isMatrix3?s.copy(n):this[t]=n}}toJSON(e){let t=e===void 0||typeof e=="string";if(!t&&e.textures[this.uuid]!==void 0)return e.textures[this.uuid];let n={metadata:{version:4.7,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(e).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,normalized:this.normalized,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(n.userData=this.userData),t||(e.textures[this.uuid]=n),n}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(e){if(this.mapping!==Vc)return e;if(e.applyMatrix3(this.matrix),e.x<0||e.x>1)switch(this.wrapS){case di:e.x=e.x-Math.floor(e.x);break;case cn:e.x=e.x<0?0:1;break;case ls:Math.abs(Math.floor(e.x)%2)===1?e.x=Math.ceil(e.x)-e.x:e.x=e.x-Math.floor(e.x);break}if(e.y<0||e.y>1)switch(this.wrapT){case di:e.y=e.y-Math.floor(e.y);break;case cn:e.y=e.y<0?0:1;break;case ls:Math.abs(Math.floor(e.y)%2)===1?e.y=Math.ceil(e.y)-e.y:e.y=e.y-Math.floor(e.y);break}return this.flipY&&(e.y=1-e.y),e}set needsUpdate(e){e===!0&&(this.version++,this.source.needsUpdate=!0)}set needsPMREMUpdate(e){e===!0&&this.pmremVersion++}};Rt.DEFAULT_IMAGE=null;Rt.DEFAULT_MAPPING=Vc;Rt.DEFAULT_ANISOTROPY=1;var et=class i{static{i.prototype.isVector4=!0}constructor(e=0,t=0,n=0,s=1){this.x=e,this.y=t,this.z=n,this.w=s}get width(){return this.z}set width(e){this.z=e}get height(){return this.w}set height(e){this.w=e}set(e,t,n,s){return this.x=e,this.y=t,this.z=n,this.w=s,this}setScalar(e){return this.x=e,this.y=e,this.z=e,this.w=e,this}setX(e){return this.x=e,this}setY(e){return this.y=e,this}setZ(e){return this.z=e,this}setW(e){return this.w=e,this}setComponent(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;case 2:this.z=t;break;case 3:this.w=t;break;default:throw new Error("THREE.Vector4: index is out of range: "+e)}return this}getComponent(e){switch(e){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("THREE.Vector4: index is out of range: "+e)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(e){return this.x=e.x,this.y=e.y,this.z=e.z,this.w=e.w!==void 0?e.w:1,this}add(e){return this.x+=e.x,this.y+=e.y,this.z+=e.z,this.w+=e.w,this}addScalar(e){return this.x+=e,this.y+=e,this.z+=e,this.w+=e,this}addVectors(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this.z=e.z+t.z,this.w=e.w+t.w,this}addScaledVector(e,t){return this.x+=e.x*t,this.y+=e.y*t,this.z+=e.z*t,this.w+=e.w*t,this}sub(e){return this.x-=e.x,this.y-=e.y,this.z-=e.z,this.w-=e.w,this}subScalar(e){return this.x-=e,this.y-=e,this.z-=e,this.w-=e,this}subVectors(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this.z=e.z-t.z,this.w=e.w-t.w,this}multiply(e){return this.x*=e.x,this.y*=e.y,this.z*=e.z,this.w*=e.w,this}multiplyScalar(e){return this.x*=e,this.y*=e,this.z*=e,this.w*=e,this}applyMatrix4(e){let t=this.x,n=this.y,s=this.z,r=this.w,a=e.elements;return this.x=a[0]*t+a[4]*n+a[8]*s+a[12]*r,this.y=a[1]*t+a[5]*n+a[9]*s+a[13]*r,this.z=a[2]*t+a[6]*n+a[10]*s+a[14]*r,this.w=a[3]*t+a[7]*n+a[11]*s+a[15]*r,this}divide(e){return this.x/=e.x,this.y/=e.y,this.z/=e.z,this.w/=e.w,this}divideScalar(e){return this.multiplyScalar(1/e)}setAxisAngleFromQuaternion(e){this.w=2*Math.acos(e.w);let t=Math.sqrt(1-e.w*e.w);return t<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=e.x/t,this.y=e.y/t,this.z=e.z/t),this}setAxisAngleFromRotationMatrix(e){let t,n,s,r,c=e.elements,l=c[0],h=c[4],f=c[8],u=c[1],d=c[5],g=c[9],y=c[2],m=c[6],p=c[10];if(Math.abs(h-u)<.01&&Math.abs(f-y)<.01&&Math.abs(g-m)<.01){if(Math.abs(h+u)<.1&&Math.abs(f+y)<.1&&Math.abs(g+m)<.1&&Math.abs(l+d+p-3)<.1)return this.set(1,0,0,0),this;t=Math.PI;let R=(l+1)/2,v=(d+1)/2,b=(p+1)/2,S=(h+u)/4,A=(f+y)/4,_=(g+m)/4;return R>v&&R>b?R<.01?(n=0,s=.707106781,r=.707106781):(n=Math.sqrt(R),s=S/n,r=A/n):v>b?v<.01?(n=.707106781,s=0,r=.707106781):(s=Math.sqrt(v),n=S/s,r=_/s):b<.01?(n=.707106781,s=.707106781,r=0):(r=Math.sqrt(b),n=A/r,s=_/r),this.set(n,s,r,t),this}let T=Math.sqrt((m-g)*(m-g)+(f-y)*(f-y)+(u-h)*(u-h));return Math.abs(T)<.001&&(T=1),this.x=(m-g)/T,this.y=(f-y)/T,this.z=(u-h)/T,this.w=Math.acos((l+d+p-1)/2),this}setFromMatrixPosition(e){let t=e.elements;return this.x=t[12],this.y=t[13],this.z=t[14],this.w=t[15],this}min(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this.z=Math.min(this.z,e.z),this.w=Math.min(this.w,e.w),this}max(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this.z=Math.max(this.z,e.z),this.w=Math.max(this.w,e.w),this}clamp(e,t){return this.x=He(this.x,e.x,t.x),this.y=He(this.y,e.y,t.y),this.z=He(this.z,e.z,t.z),this.w=He(this.w,e.w,t.w),this}clampScalar(e,t){return this.x=He(this.x,e,t),this.y=He(this.y,e,t),this.z=He(this.z,e,t),this.w=He(this.w,e,t),this}clampLength(e,t){let n=this.length();return this.divideScalar(n||1).multiplyScalar(He(n,e,t))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(e){return this.x*e.x+this.y*e.y+this.z*e.z+this.w*e.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(e){return this.normalize().multiplyScalar(e)}lerp(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this.z+=(e.z-this.z)*t,this.w+=(e.w-this.w)*t,this}lerpVectors(e,t,n){return this.x=e.x+(t.x-e.x)*n,this.y=e.y+(t.y-e.y)*n,this.z=e.z+(t.z-e.z)*n,this.w=e.w+(t.w-e.w)*n,this}equals(e){return e.x===this.x&&e.y===this.y&&e.z===this.z&&e.w===this.w}fromArray(e,t=0){return this.x=e[t],this.y=e[t+1],this.z=e[t+2],this.w=e[t+3],this}toArray(e=[],t=0){return e[t]=this.x,e[t+1]=this.y,e[t+2]=this.z,e[t+3]=this.w,e}fromBufferAttribute(e,t){return this.x=e.getX(t),this.y=e.getY(t),this.z=e.getZ(t),this.w=e.getW(t),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}},_a=class extends Pn{constructor(e=1,t=1,n={}){super(),n=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:pt,depthBuffer:!0,stencilBuffer:!1,resolveColorBuffer:!0,resolveDepthBuffer:!0,resolveStencilBuffer:!0,storeMultisampledColorBuffer:!0,storeMultisampledDepthBuffer:!0,storeMultisampledStencilBuffer:!0,depthTexture:null,samples:0,count:1,depth:1,multiview:!1,useArrayDepthTexture:!1},n),this.isRenderTarget=!0,this.width=e,this.height=t,this.depth=n.depth,this.scissor=new et(0,0,e,t),this.scissorTest=!1,this.viewport=new et(0,0,e,t),this.textures=[];let s={width:e,height:t,depth:n.depth},r=new Rt(s),a=n.count;for(let o=0;o<a;o++)this.textures[o]=r.clone(),this.textures[o].isRenderTargetTexture=!0,this.textures[o].renderTarget=this;this._setTextureOptions(n),this.depthBuffer=n.depthBuffer,this.stencilBuffer=n.stencilBuffer,this.resolveColorBuffer=n.resolveColorBuffer,this.resolveDepthBuffer=n.resolveDepthBuffer,this.resolveStencilBuffer=n.resolveStencilBuffer,this.storeMultisampledColorBuffer=n.storeMultisampledColorBuffer,this.storeMultisampledDepthBuffer=n.storeMultisampledDepthBuffer,this.storeMultisampledStencilBuffer=n.storeMultisampledStencilBuffer,this._depthTexture=null,this.depthTexture=n.depthTexture,this.samples=n.samples,this.multiview=n.multiview,this.useArrayDepthTexture=n.useArrayDepthTexture}_setTextureOptions(e={}){let t={minFilter:pt,generateMipmaps:!1,flipY:!1,internalFormat:null};e.mapping!==void 0&&(t.mapping=e.mapping),e.wrapS!==void 0&&(t.wrapS=e.wrapS),e.wrapT!==void 0&&(t.wrapT=e.wrapT),e.wrapR!==void 0&&(t.wrapR=e.wrapR),e.magFilter!==void 0&&(t.magFilter=e.magFilter),e.minFilter!==void 0&&(t.minFilter=e.minFilter),e.format!==void 0&&(t.format=e.format),e.type!==void 0&&(t.type=e.type),e.anisotropy!==void 0&&(t.anisotropy=e.anisotropy),e.colorSpace!==void 0&&(t.colorSpace=e.colorSpace),e.flipY!==void 0&&(t.flipY=e.flipY),e.generateMipmaps!==void 0&&(t.generateMipmaps=e.generateMipmaps),e.internalFormat!==void 0&&(t.internalFormat=e.internalFormat);for(let n=0;n<this.textures.length;n++)this.textures[n].setValues(t)}get texture(){return this.textures[0]}set texture(e){this.textures[0]=e}set depthTexture(e){this._depthTexture!==null&&this._depthTexture.renderTarget===this&&(this._depthTexture.renderTarget=null),e!==null&&e.renderTarget===null&&(e.renderTarget=this),this._depthTexture=e}get depthTexture(){return this._depthTexture}setSize(e,t,n=1){if(this.width!==e||this.height!==t||this.depth!==n){this.width=e,this.height=t,this.depth=n;for(let s=0,r=this.textures.length;s<r;s++)this.textures[s].image.width=e,this.textures[s].image.height=t,this.textures[s].image.depth=n,this.textures[s].isData3DTexture!==!0&&(this.textures[s].isArrayTexture=this.textures[s].image.depth>1);this.dispose()}this.viewport.set(0,0,e,t),this.scissor.set(0,0,e,t)}clone(){return new this.constructor().copy(this)}copy(e){this.width=e.width,this.height=e.height,this.depth=e.depth,this.scissor.copy(e.scissor),this.scissorTest=e.scissorTest,this.viewport.copy(e.viewport),this.textures.length=0;for(let t=0,n=e.textures.length;t<n;t++){this.textures[t]=e.textures[t].clone(),this.textures[t].isRenderTargetTexture=!0,this.textures[t].renderTarget=this;let s=Object.assign({},e.textures[t].image);this.textures[t].source=new ds(s)}if(this.depthBuffer=e.depthBuffer,this.stencilBuffer=e.stencilBuffer,this.resolveColorBuffer=e.resolveColorBuffer,this.resolveDepthBuffer=e.resolveDepthBuffer,this.resolveStencilBuffer=e.resolveStencilBuffer,this.storeMultisampledColorBuffer=e.storeMultisampledColorBuffer,this.storeMultisampledDepthBuffer=e.storeMultisampledDepthBuffer,this.storeMultisampledStencilBuffer=e.storeMultisampledStencilBuffer,e.depthTexture!==null)if(e.depthTexture.renderTarget===e){let t=e.depthTexture.clone();t.renderTarget=null,this.depthTexture=t}else this.depthTexture=e.depthTexture;return this.samples=e.samples,this.multiview=e.multiview,this.useArrayDepthTexture=e.useArrayDepthTexture,this}dispose(){this.dispatchEvent({type:"dispose"})}},Wt=class extends _a{constructor(e=1,t=1,n={}){super(e,t,n),this.isWebGLRenderTarget=!0}},Js=class extends Rt{constructor(e=null,t=1,n=1,s=1){super(null),this.isDataArrayTexture=!0,this.image={data:e,width:t,height:n,depth:s},this.magFilter=dt,this.minFilter=dt,this.wrapR=cn,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1,this.layerUpdates=new Set}copy(e){return super.copy(e),this.wrapR=e.wrapR,this}addLayerUpdate(e){this.layerUpdates.add(e)}clearLayerUpdates(){this.layerUpdates.clear()}};var xa=class extends Rt{constructor(e=null,t=1,n=1,s=1){super(null),this.isData3DTexture=!0,this.image={data:e,width:t,height:n,depth:s},this.magFilter=dt,this.minFilter=dt,this.wrapR=cn,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}copy(e){return super.copy(e),this.wrapR=e.wrapR,this}};var Ne=class i{static{i.prototype.isMatrix4=!0}constructor(e,t,n,s,r,a,o,c,l,h,f,u,d,g,y,m){this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],e!==void 0&&this.set(e,t,n,s,r,a,o,c,l,h,f,u,d,g,y,m)}set(e,t,n,s,r,a,o,c,l,h,f,u,d,g,y,m){let p=this.elements;return p[0]=e,p[4]=t,p[8]=n,p[12]=s,p[1]=r,p[5]=a,p[9]=o,p[13]=c,p[2]=l,p[6]=h,p[10]=f,p[14]=u,p[3]=d,p[7]=g,p[11]=y,p[15]=m,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new i().fromArray(this.elements)}copy(e){let t=this.elements,n=e.elements;return t[0]=n[0],t[1]=n[1],t[2]=n[2],t[3]=n[3],t[4]=n[4],t[5]=n[5],t[6]=n[6],t[7]=n[7],t[8]=n[8],t[9]=n[9],t[10]=n[10],t[11]=n[11],t[12]=n[12],t[13]=n[13],t[14]=n[14],t[15]=n[15],this}copyPosition(e){let t=this.elements,n=e.elements;return t[12]=n[12],t[13]=n[13],t[14]=n[14],this}setFromMatrix3(e){let t=e.elements;return this.set(t[0],t[3],t[6],0,t[1],t[4],t[7],0,t[2],t[5],t[8],0,0,0,0,1),this}extractBasis(e,t,n){return this.determinantAffine()===0?(e.set(1,0,0),t.set(0,1,0),n.set(0,0,1),this):(e.setFromMatrixColumn(this,0),t.setFromMatrixColumn(this,1),n.setFromMatrixColumn(this,2),this)}makeBasis(e,t,n){return this.set(e.x,t.x,n.x,0,e.y,t.y,n.y,0,e.z,t.z,n.z,0,0,0,0,1),this}extractRotation(e){if(e.determinantAffine()===0)return this.identity();let t=this.elements,n=e.elements,s=1/Zi.setFromMatrixColumn(e,0).length(),r=1/Zi.setFromMatrixColumn(e,1).length(),a=1/Zi.setFromMatrixColumn(e,2).length();return t[0]=n[0]*s,t[1]=n[1]*s,t[2]=n[2]*s,t[3]=0,t[4]=n[4]*r,t[5]=n[5]*r,t[6]=n[6]*r,t[7]=0,t[8]=n[8]*a,t[9]=n[9]*a,t[10]=n[10]*a,t[11]=0,t[12]=0,t[13]=0,t[14]=0,t[15]=1,this}makeRotationFromEuler(e){let t=this.elements,n=e.x,s=e.y,r=e.z,a=Math.cos(n),o=Math.sin(n),c=Math.cos(s),l=Math.sin(s),h=Math.cos(r),f=Math.sin(r);if(e.order==="XYZ"){let u=a*h,d=a*f,g=o*h,y=o*f;t[0]=c*h,t[4]=-c*f,t[8]=l,t[1]=d+g*l,t[5]=u-y*l,t[9]=-o*c,t[2]=y-u*l,t[6]=g+d*l,t[10]=a*c}else if(e.order==="YXZ"){let u=c*h,d=c*f,g=l*h,y=l*f;t[0]=u+y*o,t[4]=g*o-d,t[8]=a*l,t[1]=a*f,t[5]=a*h,t[9]=-o,t[2]=d*o-g,t[6]=y+u*o,t[10]=a*c}else if(e.order==="ZXY"){let u=c*h,d=c*f,g=l*h,y=l*f;t[0]=u-y*o,t[4]=-a*f,t[8]=g+d*o,t[1]=d+g*o,t[5]=a*h,t[9]=y-u*o,t[2]=-a*l,t[6]=o,t[10]=a*c}else if(e.order==="ZYX"){let u=a*h,d=a*f,g=o*h,y=o*f;t[0]=c*h,t[4]=g*l-d,t[8]=u*l+y,t[1]=c*f,t[5]=y*l+u,t[9]=d*l-g,t[2]=-l,t[6]=o*c,t[10]=a*c}else if(e.order==="YZX"){let u=a*c,d=a*l,g=o*c,y=o*l;t[0]=c*h,t[4]=y-u*f,t[8]=g*f+d,t[1]=f,t[5]=a*h,t[9]=-o*h,t[2]=-l*h,t[6]=d*f+g,t[10]=u-y*f}else if(e.order==="XZY"){let u=a*c,d=a*l,g=o*c,y=o*l;t[0]=c*h,t[4]=-f,t[8]=l*h,t[1]=u*f+y,t[5]=a*h,t[9]=d*f-g,t[2]=g*f-d,t[6]=o*h,t[10]=y*f+u}return t[3]=0,t[7]=0,t[11]=0,t[12]=0,t[13]=0,t[14]=0,t[15]=1,this}makeRotationFromQuaternion(e){return this.compose(Jf,e,$f)}lookAt(e,t,n){let s=this.elements;return Jt.subVectors(e,t),Jt.lengthSq()===0&&(Jt.z=1),Jt.normalize(),ai.crossVectors(n,Jt),ai.lengthSq()===0&&(Math.abs(n.z)===1?Jt.x+=1e-4:Jt.z+=1e-4,Jt.normalize(),ai.crossVectors(n,Jt)),ai.normalize(),Or.crossVectors(Jt,ai),s[0]=ai.x,s[4]=Or.x,s[8]=Jt.x,s[1]=ai.y,s[5]=Or.y,s[9]=Jt.y,s[2]=ai.z,s[6]=Or.z,s[10]=Jt.z,this}multiply(e){return this.multiplyMatrices(this,e)}premultiply(e){return this.multiplyMatrices(e,this)}multiplyMatrices(e,t){let n=e.elements,s=t.elements,r=this.elements,a=n[0],o=n[4],c=n[8],l=n[12],h=n[1],f=n[5],u=n[9],d=n[13],g=n[2],y=n[6],m=n[10],p=n[14],T=n[3],R=n[7],v=n[11],b=n[15],S=s[0],A=s[4],_=s[8],E=s[12],P=s[1],N=s[5],k=s[9],H=s[13],L=s[2],V=s[6],K=s[10],Z=s[14],ne=s[3],X=s[7],Q=s[11],te=s[15];return r[0]=a*S+o*P+c*L+l*ne,r[4]=a*A+o*N+c*V+l*X,r[8]=a*_+o*k+c*K+l*Q,r[12]=a*E+o*H+c*Z+l*te,r[1]=h*S+f*P+u*L+d*ne,r[5]=h*A+f*N+u*V+d*X,r[9]=h*_+f*k+u*K+d*Q,r[13]=h*E+f*H+u*Z+d*te,r[2]=g*S+y*P+m*L+p*ne,r[6]=g*A+y*N+m*V+p*X,r[10]=g*_+y*k+m*K+p*Q,r[14]=g*E+y*H+m*Z+p*te,r[3]=T*S+R*P+v*L+b*ne,r[7]=T*A+R*N+v*V+b*X,r[11]=T*_+R*k+v*K+b*Q,r[15]=T*E+R*H+v*Z+b*te,this}multiplyScalar(e){let t=this.elements;return t[0]*=e,t[4]*=e,t[8]*=e,t[12]*=e,t[1]*=e,t[5]*=e,t[9]*=e,t[13]*=e,t[2]*=e,t[6]*=e,t[10]*=e,t[14]*=e,t[3]*=e,t[7]*=e,t[11]*=e,t[15]*=e,this}determinant(){let e=this.elements,t=e[0],n=e[4],s=e[8],r=e[12],a=e[1],o=e[5],c=e[9],l=e[13],h=e[2],f=e[6],u=e[10],d=e[14],g=e[3],y=e[7],m=e[11],p=e[15],T=c*d-l*u,R=o*d-l*f,v=o*u-c*f,b=a*d-l*h,S=a*u-c*h,A=a*f-o*h;return t*(y*T-m*R+p*v)-n*(g*T-m*b+p*S)+s*(g*R-y*b+p*A)-r*(g*v-y*S+m*A)}determinantAffine(){let e=this.elements,t=e[0],n=e[4],s=e[8],r=e[1],a=e[5],o=e[9],c=e[2],l=e[6],h=e[10];return t*(a*h-o*l)-n*(r*h-o*c)+s*(r*l-a*c)}transpose(){let e=this.elements,t;return t=e[1],e[1]=e[4],e[4]=t,t=e[2],e[2]=e[8],e[8]=t,t=e[6],e[6]=e[9],e[9]=t,t=e[3],e[3]=e[12],e[12]=t,t=e[7],e[7]=e[13],e[13]=t,t=e[11],e[11]=e[14],e[14]=t,this}setPosition(e,t,n){let s=this.elements;return e.isVector3?(s[12]=e.x,s[13]=e.y,s[14]=e.z):(s[12]=e,s[13]=t,s[14]=n),this}invert(){let e=this.elements,t=e[0],n=e[1],s=e[2],r=e[3],a=e[4],o=e[5],c=e[6],l=e[7],h=e[8],f=e[9],u=e[10],d=e[11],g=e[12],y=e[13],m=e[14],p=e[15],T=t*o-n*a,R=t*c-s*a,v=t*l-r*a,b=n*c-s*o,S=n*l-r*o,A=s*l-r*c,_=h*y-f*g,E=h*m-u*g,P=h*p-d*g,N=f*m-u*y,k=f*p-d*y,H=u*p-d*m,L=T*H-R*k+v*N+b*P-S*E+A*_;if(L===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);let V=1/L;return e[0]=(o*H-c*k+l*N)*V,e[1]=(s*k-n*H-r*N)*V,e[2]=(y*A-m*S+p*b)*V,e[3]=(u*S-f*A-d*b)*V,e[4]=(c*P-a*H-l*E)*V,e[5]=(t*H-s*P+r*E)*V,e[6]=(m*v-g*A-p*R)*V,e[7]=(h*A-u*v+d*R)*V,e[8]=(a*k-o*P+l*_)*V,e[9]=(n*P-t*k-r*_)*V,e[10]=(g*S-y*v+p*T)*V,e[11]=(f*v-h*S-d*T)*V,e[12]=(o*E-a*N-c*_)*V,e[13]=(t*N-n*E+s*_)*V,e[14]=(y*R-g*b-m*T)*V,e[15]=(h*b-f*R+u*T)*V,this}scale(e){let t=this.elements,n=e.x,s=e.y,r=e.z;return t[0]*=n,t[4]*=s,t[8]*=r,t[1]*=n,t[5]*=s,t[9]*=r,t[2]*=n,t[6]*=s,t[10]*=r,t[3]*=n,t[7]*=s,t[11]*=r,this}getMaxScaleOnAxis(){let e=this.elements,t=e[0]*e[0]+e[1]*e[1]+e[2]*e[2],n=e[4]*e[4]+e[5]*e[5]+e[6]*e[6],s=e[8]*e[8]+e[9]*e[9]+e[10]*e[10];return Math.sqrt(Math.max(t,n,s))}makeTranslation(e,t,n){return e.isVector3?this.set(1,0,0,e.x,0,1,0,e.y,0,0,1,e.z,0,0,0,1):this.set(1,0,0,e,0,1,0,t,0,0,1,n,0,0,0,1),this}makeRotationX(e){let t=Math.cos(e),n=Math.sin(e);return this.set(1,0,0,0,0,t,-n,0,0,n,t,0,0,0,0,1),this}makeRotationY(e){let t=Math.cos(e),n=Math.sin(e);return this.set(t,0,n,0,0,1,0,0,-n,0,t,0,0,0,0,1),this}makeRotationZ(e){let t=Math.cos(e),n=Math.sin(e);return this.set(t,-n,0,0,n,t,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(e,t){let n=Math.cos(t),s=Math.sin(t),r=1-n,a=e.x,o=e.y,c=e.z,l=r*a,h=r*o;return this.set(l*a+n,l*o-s*c,l*c+s*o,0,l*o+s*c,h*o+n,h*c-s*a,0,l*c-s*o,h*c+s*a,r*c*c+n,0,0,0,0,1),this}makeScale(e,t,n){return this.set(e,0,0,0,0,t,0,0,0,0,n,0,0,0,0,1),this}makeShear(e,t,n,s,r,a){return this.set(1,n,r,0,e,1,a,0,t,s,1,0,0,0,0,1),this}compose(e,t,n){let s=this.elements,r=t._x,a=t._y,o=t._z,c=t._w,l=r+r,h=a+a,f=o+o,u=r*l,d=r*h,g=r*f,y=a*h,m=a*f,p=o*f,T=c*l,R=c*h,v=c*f,b=n.x,S=n.y,A=n.z;return s[0]=(1-(y+p))*b,s[1]=(d+v)*b,s[2]=(g-R)*b,s[3]=0,s[4]=(d-v)*S,s[5]=(1-(u+p))*S,s[6]=(m+T)*S,s[7]=0,s[8]=(g+R)*A,s[9]=(m-T)*A,s[10]=(1-(u+y))*A,s[11]=0,s[12]=e.x,s[13]=e.y,s[14]=e.z,s[15]=1,this}decompose(e,t,n){let s=this.elements;e.x=s[12],e.y=s[13],e.z=s[14];let r=this.determinantAffine();if(r===0)return n.set(1,1,1),t.identity(),this;let a=Zi.set(s[0],s[1],s[2]).length(),o=Zi.set(s[4],s[5],s[6]).length(),c=Zi.set(s[8],s[9],s[10]).length();r<0&&(a=-a),dn.copy(this);let l=1/a,h=1/o,f=1/c;return dn.elements[0]*=l,dn.elements[1]*=l,dn.elements[2]*=l,dn.elements[4]*=h,dn.elements[5]*=h,dn.elements[6]*=h,dn.elements[8]*=f,dn.elements[9]*=f,dn.elements[10]*=f,t.setFromRotationMatrix(dn),n.x=a,n.y=o,n.z=c,this}makePerspective(e,t,n,s,r,a,o=_n,c=!1){let l=this.elements,h=2*r/(t-e),f=2*r/(n-s),u=(t+e)/(t-e),d=(n+s)/(n-s),g,y;if(c)g=r/(a-r),y=a*r/(a-r);else if(o===_n)g=-(a+r)/(a-r),y=-2*a*r/(a-r);else if(o===hs)g=-a/(a-r),y=-a*r/(a-r);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+o);return l[0]=h,l[4]=0,l[8]=u,l[12]=0,l[1]=0,l[5]=f,l[9]=d,l[13]=0,l[2]=0,l[6]=0,l[10]=g,l[14]=y,l[3]=0,l[7]=0,l[11]=-1,l[15]=0,this}makeOrthographic(e,t,n,s,r,a,o=_n,c=!1){let l=this.elements,h=2/(t-e),f=2/(n-s),u=-(t+e)/(t-e),d=-(n+s)/(n-s),g,y;if(c)g=1/(a-r),y=a/(a-r);else if(o===_n)g=-2/(a-r),y=-(a+r)/(a-r);else if(o===hs)g=-1/(a-r),y=-r/(a-r);else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+o);return l[0]=h,l[4]=0,l[8]=0,l[12]=u,l[1]=0,l[5]=f,l[9]=0,l[13]=d,l[2]=0,l[6]=0,l[10]=g,l[14]=y,l[3]=0,l[7]=0,l[11]=0,l[15]=1,this}equals(e){let t=this.elements,n=e.elements;for(let s=0;s<16;s++)if(t[s]!==n[s])return!1;return!0}fromArray(e,t=0){for(let n=0;n<16;n++)this.elements[n]=e[n+t];return this}toArray(e=[],t=0){let n=this.elements;return e[t]=n[0],e[t+1]=n[1],e[t+2]=n[2],e[t+3]=n[3],e[t+4]=n[4],e[t+5]=n[5],e[t+6]=n[6],e[t+7]=n[7],e[t+8]=n[8],e[t+9]=n[9],e[t+10]=n[10],e[t+11]=n[11],e[t+12]=n[12],e[t+13]=n[13],e[t+14]=n[14],e[t+15]=n[15],e}},Zi=new O,dn=new Ne,Jf=new O(0,0,0),$f=new O(1,1,1),ai=new O,Or=new O,Jt=new O,uh=new Ne,fh=new Qt,Ln=class i{constructor(e=0,t=0,n=0,s=i.DEFAULT_ORDER){this.isEuler=!0,this._x=e,this._y=t,this._z=n,this._order=s}get x(){return this._x}set x(e){this._x=e,this._onChangeCallback()}get y(){return this._y}set y(e){this._y=e,this._onChangeCallback()}get z(){return this._z}set z(e){this._z=e,this._onChangeCallback()}get order(){return this._order}set order(e){this._order=e,this._onChangeCallback()}set(e,t,n,s=this._order){return this._x=e,this._y=t,this._z=n,this._order=s,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(e){return this._x=e._x,this._y=e._y,this._z=e._z,this._order=e._order,this._onChangeCallback(),this}setFromRotationMatrix(e,t=this._order,n=!0){let s=e.elements,r=s[0],a=s[4],o=s[8],c=s[1],l=s[5],h=s[9],f=s[2],u=s[6],d=s[10];switch(t){case"XYZ":this._y=Math.asin(He(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(-h,d),this._z=Math.atan2(-a,r)):(this._x=Math.atan2(u,l),this._z=0);break;case"YXZ":this._x=Math.asin(-He(h,-1,1)),Math.abs(h)<.9999999?(this._y=Math.atan2(o,d),this._z=Math.atan2(c,l)):(this._y=Math.atan2(-f,r),this._z=0);break;case"ZXY":this._x=Math.asin(He(u,-1,1)),Math.abs(u)<.9999999?(this._y=Math.atan2(-f,d),this._z=Math.atan2(-a,l)):(this._y=0,this._z=Math.atan2(c,r));break;case"ZYX":this._y=Math.asin(-He(f,-1,1)),Math.abs(f)<.9999999?(this._x=Math.atan2(u,d),this._z=Math.atan2(c,r)):(this._x=0,this._z=Math.atan2(-a,l));break;case"YZX":this._z=Math.asin(He(c,-1,1)),Math.abs(c)<.9999999?(this._x=Math.atan2(-h,l),this._y=Math.atan2(-f,r)):(this._x=0,this._y=Math.atan2(o,d));break;case"XZY":this._z=Math.asin(-He(a,-1,1)),Math.abs(a)<.9999999?(this._x=Math.atan2(u,l),this._y=Math.atan2(o,r)):(this._x=Math.atan2(-h,d),this._y=0);break;default:be("Euler: .setFromRotationMatrix() encountered an unknown order: "+t)}return this._order=t,n===!0&&this._onChangeCallback(),this}setFromQuaternion(e,t,n){return uh.makeRotationFromQuaternion(e),this.setFromRotationMatrix(uh,t,n)}setFromVector3(e,t=this._order){return this.set(e.x,e.y,e.z,t)}reorder(e){return fh.setFromEuler(this),this.setFromQuaternion(fh,e)}equals(e){return e._x===this._x&&e._y===this._y&&e._z===this._z&&e._order===this._order}fromArray(e){return this._x=e[0],this._y=e[1],this._z=e[2],e[3]!==void 0&&(this._order=e[3]),this._onChangeCallback(),this}toArray(e=[],t=0){return e[t]=this._x,e[t+1]=this._y,e[t+2]=this._z,e[t+3]=this._order,e}_onChange(e){return this._onChangeCallback=e,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}};Ln.DEFAULT_ORDER="XYZ";var $s=class{constructor(){this.mask=1}set(e){this.mask=(1<<e|0)>>>0}enable(e){this.mask|=1<<e|0}enableAll(){this.mask=-1}toggle(e){this.mask^=1<<e|0}disable(e){this.mask&=~(1<<e|0)}disableAll(){this.mask=0}test(e){return(this.mask&e.mask)!==0}isEnabled(e){return(this.mask&(1<<e|0))!==0}},jf=0,dh=new O,Ki=new Qt,Vn=new Ne,Ur=new O,Fs=new O,Qf=new O,ed=new Qt,ph=new O(1,0,0),mh=new O(0,1,0),Mh=new O(0,0,1),gh={type:"added"},td={type:"removed"},Ji={type:"childadded",child:null},Jo={type:"childremoved",child:null},ut=class i extends Pn{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:jf++}),this.uuid=xn(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=i.DEFAULT_UP.clone();let e=new O,t=new Ln,n=new Qt,s=new O(1,1,1);function r(){n.setFromEuler(t,!1)}function a(){t.setFromQuaternion(n,void 0,!1)}t._onChange(r),n._onChange(a),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:e},rotation:{configurable:!0,enumerable:!0,value:t},quaternion:{configurable:!0,enumerable:!0,value:n},scale:{configurable:!0,enumerable:!0,value:s},modelViewMatrix:{value:new Ne},normalMatrix:{value:new Ie}}),this.matrix=new Ne,this.matrixWorld=new Ne,this.matrixAutoUpdate=i.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=i.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new $s,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.customDepthMaterial=void 0,this.customDistanceMaterial=void 0,this.static=!1,this.userData={},this.pivot=null}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(e){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(e),this.matrix.decompose(this.position,this.quaternion,this.scale)}applyQuaternion(e){return this.quaternion.premultiply(e),this}setRotationFromAxisAngle(e,t){this.quaternion.setFromAxisAngle(e,t)}setRotationFromEuler(e){this.quaternion.setFromEuler(e,!0)}setRotationFromMatrix(e){this.quaternion.setFromRotationMatrix(e)}setRotationFromQuaternion(e){this.quaternion.copy(e)}rotateOnAxis(e,t){return Ki.setFromAxisAngle(e,t),this.quaternion.multiply(Ki),this}rotateOnWorldAxis(e,t){return Ki.setFromAxisAngle(e,t),this.quaternion.premultiply(Ki),this}rotateX(e){return this.rotateOnAxis(ph,e)}rotateY(e){return this.rotateOnAxis(mh,e)}rotateZ(e){return this.rotateOnAxis(Mh,e)}translateOnAxis(e,t){return dh.copy(e).applyQuaternion(this.quaternion),this.position.add(dh.multiplyScalar(t)),this}translateX(e){return this.translateOnAxis(ph,e)}translateY(e){return this.translateOnAxis(mh,e)}translateZ(e){return this.translateOnAxis(Mh,e)}localToWorld(e){return this.updateWorldMatrix(!0,!1),e.applyMatrix4(this.matrixWorld)}worldToLocal(e){return this.updateWorldMatrix(!0,!1),e.applyMatrix4(Vn.copy(this.matrixWorld).invert())}lookAt(e,t,n){e.isVector3?Ur.copy(e):Ur.set(e,t,n);let s=this.parent;this.updateWorldMatrix(!0,!1),Fs.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?Vn.lookAt(Fs,Ur,this.up):Vn.lookAt(Ur,Fs,this.up),this.quaternion.setFromRotationMatrix(Vn),s&&(Vn.extractRotation(s.matrixWorld),Ki.setFromRotationMatrix(Vn),this.quaternion.premultiply(Ki.invert()))}add(e){if(arguments.length>1){for(let t=0;t<arguments.length;t++)this.add(arguments[t]);return this}return e===this?(ze("Object3D.add: object can't be added as a child of itself.",e),this):(e&&e.isObject3D?(e.removeFromParent(),e.parent=this,this.children.push(e),e.dispatchEvent(gh),Ji.child=e,this.dispatchEvent(Ji),Ji.child=null):ze("Object3D.add: object not an instance of THREE.Object3D.",e),this)}remove(e){if(arguments.length>1){for(let n=0;n<arguments.length;n++)this.remove(arguments[n]);return this}let t=this.children.indexOf(e);return t!==-1&&(e.parent=null,this.children.splice(t,1),e.dispatchEvent(td),Jo.child=e,this.dispatchEvent(Jo),Jo.child=null),this}removeFromParent(){let e=this.parent;return e!==null&&e.remove(this),this}clear(){return this.remove(...this.children)}attach(e){return this.updateWorldMatrix(!0,!1),Vn.copy(this.matrixWorld).invert(),e.parent!==null&&(e.parent.updateWorldMatrix(!0,!1),Vn.multiply(e.parent.matrixWorld)),e.applyMatrix4(Vn),e.removeFromParent(),e.parent=this,this.children.push(e),e.updateWorldMatrix(!1,!0),e.dispatchEvent(gh),Ji.child=e,this.dispatchEvent(Ji),Ji.child=null,this}getObjectById(e){return this.getObjectByProperty("id",e)}getObjectByName(e){return this.getObjectByProperty("name",e)}getObjectByProperty(e,t){if(this[e]===t)return this;for(let n=0,s=this.children.length;n<s;n++){let a=this.children[n].getObjectByProperty(e,t);if(a!==void 0)return a}}getObjectsByProperty(e,t,n=[]){this[e]===t&&n.push(this);let s=this.children;for(let r=0,a=s.length;r<a;r++)s[r].getObjectsByProperty(e,t,n);return n}getWorldPosition(e){return this.updateWorldMatrix(!0,!1),e.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(e){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Fs,e,Qf),e}getWorldScale(e){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Fs,ed,e),e}getWorldDirection(e){this.updateWorldMatrix(!0,!1);let t=this.matrixWorld.elements;return e.set(t[8],t[9],t[10]).normalize()}raycast(){}intersectsFrustum(){}traverse(e){e(this);let t=this.children;for(let n=0,s=t.length;n<s;n++)t[n].traverse(e)}traverseVisible(e){if(this.visible===!1)return;e(this);let t=this.children;for(let n=0,s=t.length;n<s;n++)t[n].traverseVisible(e)}traverseAncestors(e){let t=this.parent;t!==null&&(e(t),t.traverseAncestors(e))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale);let e=this.pivot;if(e!==null){let t=e.x,n=e.y,s=e.z,r=this.matrix.elements;r[12]+=t-r[0]*t-r[4]*n-r[8]*s,r[13]+=n-r[1]*t-r[5]*n-r[9]*s,r[14]+=s-r[2]*t-r[6]*n-r[10]*s}this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(e){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||e)&&(this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),this.matrixWorldNeedsUpdate=!1,e=!0);let t=this.children;for(let n=0,s=t.length;n<s;n++)t[n].updateMatrixWorld(e)}updateWorldMatrix(e,t,n=!1){let s=this.parent;if(e===!0&&s!==null&&s.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||n)&&(this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),this.matrixWorldNeedsUpdate=!1,n=!0),t===!0){let r=this.children;for(let a=0,o=r.length;a<o;a++)r[a].updateWorldMatrix(!1,!0,n)}}toJSON(e){let t=e===void 0||typeof e=="string",n={};t&&(e={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},n.metadata={version:4.7,type:"Object",generator:"Object3D.toJSON"});let s={};s.uuid=this.uuid,s.type=this.type,s.name=this.name,s.castShadow=this.castShadow,s.receiveShadow=this.receiveShadow,s.visible=this.visible,s.frustumCulled=this.frustumCulled,s.renderOrder=this.renderOrder,s.static=this.static,s.matrixAutoUpdate=this.matrixAutoUpdate,Object.keys(this.userData).length>0&&(s.userData=this.userData),s.layers=this.layers.mask,s.matrix=this.matrix.toArray(),s.up=this.up.toArray(),this.pivot!==null&&(s.pivot=this.pivot.toArray()),this.morphTargetDictionary!==void 0&&(s.morphTargetDictionary=Object.assign({},this.morphTargetDictionary)),this.morphTargetInfluences!==void 0&&(s.morphTargetInfluences=this.morphTargetInfluences.slice()),this.isInstancedMesh&&(s.type="InstancedMesh",s.count=this.count,s.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(s.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(s.type="BatchedMesh",s.perObjectFrustumCulled=this.perObjectFrustumCulled,s.sortObjects=this.sortObjects,s.drawRanges=this._drawRanges,s.reservedRanges=this._reservedRanges,s.geometryInfo=this._geometryInfo.map(o=>({...o,boundingBox:o.boundingBox?o.boundingBox.toJSON():void 0,boundingSphere:o.boundingSphere?o.boundingSphere.toJSON():void 0})),s.instanceInfo=this._instanceInfo.map(o=>({...o})),s.availableInstanceIds=this._availableInstanceIds.slice(),s.availableGeometryIds=this._availableGeometryIds.slice(),s.nextIndexStart=this._nextIndexStart,s.nextVertexStart=this._nextVertexStart,s.geometryCount=this._geometryCount,s.maxInstanceCount=this._maxInstanceCount,s.maxVertexCount=this._maxVertexCount,s.maxIndexCount=this._maxIndexCount,s.geometryInitialized=this._geometryInitialized,s.matricesTexture=this._matricesTexture.toJSON(e),s.indirectTexture=this._indirectTexture.toJSON(e),this._colorsTexture!==null&&(s.colorsTexture=this._colorsTexture.toJSON(e)),this.boundingSphere!==null&&(s.boundingSphere=this.boundingSphere.toJSON()),this.boundingBox!==null&&(s.boundingBox=this.boundingBox.toJSON()));function r(o,c){return o[c.uuid]===void 0&&(o[c.uuid]=c.toJSON(e)),c.uuid}if(this.isScene)this.background&&(this.background.isColor?s.background=this.background.toJSON():this.background.isTexture&&(s.background=this.background.toJSON(e).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(s.environment=this.environment.toJSON(e).uuid);else if(this.isMesh||this.isLine||this.isPoints){s.geometry=r(e.geometries,this.geometry);let o=this.geometry.parameters;if(o!==void 0&&o.shapes!==void 0){let c=o.shapes;if(Array.isArray(c))for(let l=0,h=c.length;l<h;l++){let f=c[l];r(e.shapes,f)}else r(e.shapes,c)}}if(this.isSkinnedMesh&&(s.bindMode=this.bindMode,s.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(r(e.skeletons,this.skeleton),s.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){let o=[];for(let c=0,l=this.material.length;c<l;c++)o.push(r(e.materials,this.material[c]));s.material=o}else s.material=r(e.materials,this.material);if(this.children.length>0){s.children=[];for(let o=0;o<this.children.length;o++)s.children.push(this.children[o].toJSON(e).object)}if(this.animations.length>0){s.animations=[];for(let o=0;o<this.animations.length;o++){let c=this.animations[o];s.animations.push(r(e.animations,c))}}if(t){let o=a(e.geometries),c=a(e.materials),l=a(e.textures),h=a(e.images),f=a(e.shapes),u=a(e.skeletons),d=a(e.animations),g=a(e.nodes);o.length>0&&(n.geometries=o),c.length>0&&(n.materials=c),l.length>0&&(n.textures=l),h.length>0&&(n.images=h),f.length>0&&(n.shapes=f),u.length>0&&(n.skeletons=u),d.length>0&&(n.animations=d),g.length>0&&(n.nodes=g)}return n.object=s,n;function a(o){let c=[];for(let l in o){let h=o[l];delete h.metadata,c.push(h)}return c}}clone(e){return new this.constructor().copy(this,e)}copy(e,t=!0){if(this.name=e.name,this.up.copy(e.up),this.position.copy(e.position),this.rotation.order=e.rotation.order,this.quaternion.copy(e.quaternion),this.scale.copy(e.scale),this.pivot=e.pivot!==null?e.pivot.clone():null,this.matrix.copy(e.matrix),this.matrixWorld.copy(e.matrixWorld),this.matrixAutoUpdate=e.matrixAutoUpdate,this.matrixWorldAutoUpdate=e.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=e.matrixWorldNeedsUpdate,this.layers.mask=e.layers.mask,this.visible=e.visible,this.castShadow=e.castShadow,this.receiveShadow=e.receiveShadow,this.frustumCulled=e.frustumCulled,this.renderOrder=e.renderOrder,this.static=e.static,this.animations=e.animations.slice(),this.userData=JSON.parse(JSON.stringify(e.userData)),t===!0)for(let n=0;n<e.children.length;n++){let s=e.children[n];this.add(s.clone())}return this}dispose(){this.dispatchEvent({type:"dispose"})}};ut.DEFAULT_UP=new O(0,1,0);ut.DEFAULT_MATRIX_AUTO_UPDATE=!0;ut.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;var jt=class extends ut{constructor(){super(),this.isGroup=!0,this.type="Group"}},nd={type:"move"},ps=class{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new jt,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new jt,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new O,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new O),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new jt,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new O,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new O,this._grip.eventsEnabled=!1),this._grip}dispatchEvent(e){return this._targetRay!==null&&this._targetRay.dispatchEvent(e),this._grip!==null&&this._grip.dispatchEvent(e),this._hand!==null&&this._hand.dispatchEvent(e),this}connect(e){if(e&&e.hand){let t=this._hand;if(t)for(let n of e.hand.values())this._getHandJoint(t,n)}return this.dispatchEvent({type:"connected",data:e}),this}disconnect(e){return this.dispatchEvent({type:"disconnected",data:e}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(e,t,n){let s=null,r=null,a=null,o=this._targetRay,c=this._grip,l=this._hand;if(e&&t.session.visibilityState!=="visible-blurred"){if(l&&e.hand){a=!0;for(let y of e.hand.values()){let m=t.getJointPose(y,n),p=this._getHandJoint(l,y);m!==null&&(p.matrix.fromArray(m.transform.matrix),p.matrix.decompose(p.position,p.rotation,p.scale),p.matrixWorldNeedsUpdate=!0,p.jointRadius=m.radius),p.visible=m!==null}let h=l.joints["index-finger-tip"],f=l.joints["thumb-tip"],u=h.position.distanceTo(f.position),d=.02,g=.005;l.inputState.pinching&&u>d+g?(l.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:e.handedness,target:this})):!l.inputState.pinching&&u<=d-g&&(l.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:e.handedness,target:this}))}else c!==null&&e.gripSpace&&(r=t.getPose(e.gripSpace,n),r!==null&&(c.matrix.fromArray(r.transform.matrix),c.matrix.decompose(c.position,c.rotation,c.scale),c.matrixWorldNeedsUpdate=!0,r.linearVelocity?(c.hasLinearVelocity=!0,c.linearVelocity.copy(r.linearVelocity)):c.hasLinearVelocity=!1,r.angularVelocity?(c.hasAngularVelocity=!0,c.angularVelocity.copy(r.angularVelocity)):c.hasAngularVelocity=!1,c.eventsEnabled&&c.dispatchEvent({type:"gripUpdated",data:e,target:this})));o!==null&&(s=t.getPose(e.targetRaySpace,n),s===null&&r!==null&&(s=r),s!==null&&(o.matrix.fromArray(s.transform.matrix),o.matrix.decompose(o.position,o.rotation,o.scale),o.matrixWorldNeedsUpdate=!0,s.linearVelocity?(o.hasLinearVelocity=!0,o.linearVelocity.copy(s.linearVelocity)):o.hasLinearVelocity=!1,s.angularVelocity?(o.hasAngularVelocity=!0,o.angularVelocity.copy(s.angularVelocity)):o.hasAngularVelocity=!1,this.dispatchEvent(nd)))}return o!==null&&(o.visible=s!==null),c!==null&&(c.visible=r!==null),l!==null&&(l.visible=a!==null),this}_getHandJoint(e,t){if(e.joints[t.jointName]===void 0){let n=new jt;n.matrixAutoUpdate=!1,n.visible=!1,e.joints[t.jointName]=n,e.add(n)}return e.joints[t.jointName]}},Au={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},oi={h:0,s:0,l:0},Fr={h:0,s:0,l:0};function $o(i,e,t){return t<0&&(t+=1),t>1&&(t-=1),t<1/6?i+(e-i)*6*t:t<1/2?e:t<2/3?i+(e-i)*6*(2/3-t):i}var Ce=class{constructor(e,t,n){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(e,t,n)}set(e,t,n){if(t===void 0&&n===void 0){let s=e;s&&s.isColor?this.copy(s):typeof s=="number"?this.setHex(s):typeof s=="string"&&this.setStyle(s)}else this.setRGB(e,t,n);return this}setScalar(e){return this.r=e,this.g=e,this.b=e,this}setHex(e,t=vt){return e=Math.floor(e),this.r=(e>>16&255)/255,this.g=(e>>8&255)/255,this.b=(e&255)/255,Fe.colorSpaceToWorking(this,t),this}setRGB(e,t,n,s=Fe.workingColorSpace){return this.r=e,this.g=t,this.b=n,Fe.colorSpaceToWorking(this,s),this}setHSL(e,t,n,s=Fe.workingColorSpace){if(e=$c(e,1),t=He(t,0,1),n=He(n,0,1),t===0)this.r=this.g=this.b=n;else{let r=n<=.5?n*(1+t):n+t-n*t,a=2*n-r;this.r=$o(a,r,e+1/3),this.g=$o(a,r,e),this.b=$o(a,r,e-1/3)}return Fe.colorSpaceToWorking(this,s),this}setStyle(e,t=vt){function n(r){r!==void 0&&parseFloat(r)<1&&be("Color: Alpha component of "+e+" will be ignored.")}let s;if(s=/^(\w+)\(([^\)]*)\)/.exec(e)){let r,a=s[1],o=s[2];switch(a){case"rgb":case"rgba":if(r=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(o))return n(r[4]),this.setRGB(Math.min(255,parseInt(r[1],10))/255,Math.min(255,parseInt(r[2],10))/255,Math.min(255,parseInt(r[3],10))/255,t);if(r=/^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(o))return n(r[4]),this.setRGB(Math.min(100,parseInt(r[1],10))/100,Math.min(100,parseInt(r[2],10))/100,Math.min(100,parseInt(r[3],10))/100,t);break;case"hsl":case"hsla":if(r=/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)\%\s*,\s*(\d*\.?\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(o))return n(r[4]),this.setHSL(parseFloat(r[1])/360,parseFloat(r[2])/100,parseFloat(r[3])/100,t);break;default:be("Color: Unknown color model "+e)}}else if(s=/^\#([A-Fa-f\d]+)$/.exec(e)){let r=s[1],a=r.length;if(a===3)return this.setRGB(parseInt(r.charAt(0),16)/15,parseInt(r.charAt(1),16)/15,parseInt(r.charAt(2),16)/15,t);if(a===6)return this.setHex(parseInt(r,16),t);be("Color: Invalid hex color "+e)}else if(e&&e.length>0)return this.setColorName(e,t);return this}setColorName(e,t=vt){let n=Au[e.toLowerCase()];return n!==void 0?this.setHex(n,t):be("Color: Unknown color "+e),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(e){return this.r=e.r,this.g=e.g,this.b=e.b,this}copySRGBToLinear(e){return this.r=Yn(e.r),this.g=Yn(e.g),this.b=Yn(e.b),this}copyLinearToSRGB(e){return this.r=os(e.r),this.g=os(e.g),this.b=os(e.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(e=vt){return Fe.workingToColorSpace(Lt.copy(this),e),Math.round(He(Lt.r*255,0,255))*65536+Math.round(He(Lt.g*255,0,255))*256+Math.round(He(Lt.b*255,0,255))}getHexString(e=vt){return("000000"+this.getHex(e).toString(16)).slice(-6)}getHSL(e,t=Fe.workingColorSpace){Fe.workingToColorSpace(Lt.copy(this),t);let n=Lt.r,s=Lt.g,r=Lt.b,a=Math.max(n,s,r),o=Math.min(n,s,r),c,l,h=(o+a)/2;if(o===a)c=0,l=0;else{let f=a-o;switch(l=h<=.5?f/(a+o):f/(2-a-o),a){case n:c=(s-r)/f+(s<r?6:0);break;case s:c=(r-n)/f+2;break;case r:c=(n-s)/f+4;break}c/=6}return e.h=c,e.s=l,e.l=h,e}getRGB(e,t=Fe.workingColorSpace){return Fe.workingToColorSpace(Lt.copy(this),t),e.r=Lt.r,e.g=Lt.g,e.b=Lt.b,e}getStyle(e=vt){Fe.workingToColorSpace(Lt.copy(this),e);let t=Lt.r,n=Lt.g,s=Lt.b;return e!==vt?`color(${e} ${t.toFixed(3)} ${n.toFixed(3)} ${s.toFixed(3)})`:`rgb(${Math.round(t*255)},${Math.round(n*255)},${Math.round(s*255)})`}offsetHSL(e,t,n){return this.getHSL(oi),this.setHSL(oi.h+e,oi.s+t,oi.l+n)}add(e){return this.r+=e.r,this.g+=e.g,this.b+=e.b,this}addColors(e,t){return this.r=e.r+t.r,this.g=e.g+t.g,this.b=e.b+t.b,this}addScalar(e){return this.r+=e,this.g+=e,this.b+=e,this}sub(e){return this.r=Math.max(0,this.r-e.r),this.g=Math.max(0,this.g-e.g),this.b=Math.max(0,this.b-e.b),this}multiply(e){return this.r*=e.r,this.g*=e.g,this.b*=e.b,this}multiplyScalar(e){return this.r*=e,this.g*=e,this.b*=e,this}lerp(e,t){return this.r+=(e.r-this.r)*t,this.g+=(e.g-this.g)*t,this.b+=(e.b-this.b)*t,this}lerpColors(e,t,n){return this.r=e.r+(t.r-e.r)*n,this.g=e.g+(t.g-e.g)*n,this.b=e.b+(t.b-e.b)*n,this}lerpHSL(e,t){this.getHSL(oi),e.getHSL(Fr);let n=Ys(oi.h,Fr.h,t),s=Ys(oi.s,Fr.s,t),r=Ys(oi.l,Fr.l,t);return this.setHSL(n,s,r),this}setFromVector3(e){return this.r=e.x,this.g=e.y,this.b=e.z,this}applyMatrix3(e){let t=this.r,n=this.g,s=this.b,r=e.elements;return this.r=r[0]*t+r[3]*n+r[6]*s,this.g=r[1]*t+r[4]*n+r[7]*s,this.b=r[2]*t+r[5]*n+r[8]*s,this}equals(e){return e.r===this.r&&e.g===this.g&&e.b===this.b}fromArray(e,t=0){return this.r=e[t],this.g=e[t+1],this.b=e[t+2],this}toArray(e=[],t=0){return e[t]=this.r,e[t+1]=this.g,e[t+2]=this.b,e}fromBufferAttribute(e,t){return this.r=e.getX(t),this.g=e.getY(t),this.b=e.getZ(t),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}},Lt=new Ce;Ce.NAMES=Au;var js=class extends ut{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.backgroundRotation=new Ln,this.environmentIntensity=1,this.environmentRotation=new Ln,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(e,t){return super.copy(e,t),e.background!==null&&(this.background=e.background.clone()),e.environment!==null&&(this.environment=e.environment.clone()),e.fog!==null&&(this.fog=e.fog.clone()),this.backgroundBlurriness=e.backgroundBlurriness,this.backgroundIntensity=e.backgroundIntensity,this.backgroundRotation.copy(e.backgroundRotation),this.environmentIntensity=e.environmentIntensity,this.environmentRotation.copy(e.environmentRotation),e.overrideMaterial!==null&&(this.overrideMaterial=e.overrideMaterial.clone()),this.matrixAutoUpdate=e.matrixAutoUpdate,this}toJSON(e){let t=super.toJSON(e);return this.fog!==null&&(t.object.fog=this.fog.toJSON()),t.object.backgroundBlurriness=this.backgroundBlurriness,t.object.backgroundIntensity=this.backgroundIntensity,t.object.backgroundRotation=this.backgroundRotation.toArray(),t.object.environmentIntensity=this.environmentIntensity,t.object.environmentRotation=this.environmentRotation.toArray(),t}},pn=new O,Gn=new O,jo=new O,Hn=new O,$i=new O,ji=new O,_h=new O,Qo=new O,ec=new O,tc=new O,nc=new et,ic=new et,sc=new et,fi=class i{constructor(e=new O,t=new O,n=new O){this.a=e,this.b=t,this.c=n}static getNormal(e,t,n,s){s.subVectors(n,t),pn.subVectors(e,t),s.cross(pn);let r=s.lengthSq();return r>0?s.multiplyScalar(1/Math.sqrt(r)):s.set(0,0,0)}static getBarycoord(e,t,n,s,r){pn.subVectors(s,t),Gn.subVectors(n,t),jo.subVectors(e,t);let a=pn.dot(pn),o=pn.dot(Gn),c=pn.dot(jo),l=Gn.dot(Gn),h=Gn.dot(jo),f=a*l-o*o;if(f===0)return r.set(0,0,0),null;let u=1/f,d=(l*c-o*h)*u,g=(a*h-o*c)*u;return r.set(1-d-g,g,d)}static containsPoint(e,t,n,s){return this.getBarycoord(e,t,n,s,Hn)===null?!1:Hn.x>=0&&Hn.y>=0&&Hn.x+Hn.y<=1}static getInterpolation(e,t,n,s,r,a,o,c){return this.getBarycoord(e,t,n,s,Hn)===null?(c.x=0,c.y=0,"z"in c&&(c.z=0),"w"in c&&(c.w=0),null):(c.setScalar(0),c.addScaledVector(r,Hn.x),c.addScaledVector(a,Hn.y),c.addScaledVector(o,Hn.z),c)}static getInterpolatedAttribute(e,t,n,s,r,a){return nc.setScalar(0),ic.setScalar(0),sc.setScalar(0),nc.fromBufferAttribute(e,t),ic.fromBufferAttribute(e,n),sc.fromBufferAttribute(e,s),a.setScalar(0),a.addScaledVector(nc,r.x),a.addScaledVector(ic,r.y),a.addScaledVector(sc,r.z),a}static isFrontFacing(e,t,n,s){return pn.subVectors(n,t),Gn.subVectors(e,t),pn.cross(Gn).dot(s)<0}set(e,t,n){return this.a.copy(e),this.b.copy(t),this.c.copy(n),this}setFromPointsAndIndices(e,t,n,s){return this.a.copy(e[t]),this.b.copy(e[n]),this.c.copy(e[s]),this}setFromAttributeAndIndices(e,t,n,s){return this.a.fromBufferAttribute(e,t),this.b.fromBufferAttribute(e,n),this.c.fromBufferAttribute(e,s),this}clone(){return new this.constructor().copy(this)}copy(e){return this.a.copy(e.a),this.b.copy(e.b),this.c.copy(e.c),this}getArea(){return pn.subVectors(this.c,this.b),Gn.subVectors(this.a,this.b),pn.cross(Gn).length()*.5}getMidpoint(e){return e.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(e){return i.getNormal(this.a,this.b,this.c,e)}getPlane(e){return e.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(e,t){return i.getBarycoord(e,this.a,this.b,this.c,t)}getInterpolation(e,t,n,s,r){return i.getInterpolation(e,this.a,this.b,this.c,t,n,s,r)}containsPoint(e){return i.containsPoint(e,this.a,this.b,this.c)}isFrontFacing(e){return i.isFrontFacing(this.a,this.b,this.c,e)}intersectsBox(e){return e.intersectsTriangle(this)}closestPointToPoint(e,t){let n=this.a,s=this.b,r=this.c,a,o;$i.subVectors(s,n),ji.subVectors(r,n),Qo.subVectors(e,n);let c=$i.dot(Qo),l=ji.dot(Qo);if(c<=0&&l<=0)return t.copy(n);ec.subVectors(e,s);let h=$i.dot(ec),f=ji.dot(ec);if(h>=0&&f<=h)return t.copy(s);let u=c*f-h*l;if(u<=0&&c>=0&&h<=0)return a=c/(c-h),t.copy(n).addScaledVector($i,a);tc.subVectors(e,r);let d=$i.dot(tc),g=ji.dot(tc);if(g>=0&&d<=g)return t.copy(r);let y=d*l-c*g;if(y<=0&&l>=0&&g<=0)return o=l/(l-g),t.copy(n).addScaledVector(ji,o);let m=h*g-d*f;if(m<=0&&f-h>=0&&d-g>=0)return _h.subVectors(r,s),o=(f-h)/(f-h+(d-g)),t.copy(s).addScaledVector(_h,o);let p=1/(m+y+u);return a=y*p,o=u*p,t.copy(n).addScaledVector($i,a).addScaledVector(ji,o)}equals(e){return e.a.equals(this.a)&&e.b.equals(this.b)&&e.c.equals(this.c)}},en=class{constructor(e=new O(1/0,1/0,1/0),t=new O(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=e,this.max=t}set(e,t){return this.min.copy(e),this.max.copy(t),this}setFromArray(e){this.makeEmpty();for(let t=0,n=e.length;t<n;t+=3)this.expandByPoint(mn.fromArray(e,t));return this}setFromBufferAttribute(e){this.makeEmpty();for(let t=0,n=e.count;t<n;t++)this.expandByPoint(mn.fromBufferAttribute(e,t));return this}setFromPoints(e){this.makeEmpty();for(let t=0,n=e.length;t<n;t++)this.expandByPoint(e[t]);return this}setFromCenterAndSize(e,t){let n=mn.copy(t).multiplyScalar(.5);return this.min.copy(e).sub(n),this.max.copy(e).add(n),this}setFromObject(e,t=!1){return this.makeEmpty(),this.expandByObject(e,t)}clone(){return new this.constructor().copy(this)}copy(e){return this.min.copy(e.min),this.max.copy(e.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(e){return this.isEmpty()?e.set(0,0,0):e.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(e){return this.isEmpty()?e.set(0,0,0):e.subVectors(this.max,this.min)}expandByPoint(e){return this.min.min(e),this.max.max(e),this}expandByVector(e){return this.min.sub(e),this.max.add(e),this}expandByScalar(e){return this.min.addScalar(-e),this.max.addScalar(e),this}expandByObject(e,t=!1){e.updateWorldMatrix(!1,!1);let n=e.geometry;if(n!==void 0){let r=n.getAttribute("position");if(t===!0&&r!==void 0&&e.isInstancedMesh!==!0)for(let a=0,o=r.count;a<o;a++)e.isMesh===!0?e.getVertexPosition(a,mn):mn.fromBufferAttribute(r,a),mn.applyMatrix4(e.matrixWorld),this.expandByPoint(mn);else e.boundingBox!==void 0?(e.boundingBox===null&&e.computeBoundingBox(),Br.copy(e.boundingBox)):(n.boundingBox===null&&n.computeBoundingBox(),Br.copy(n.boundingBox)),Br.applyMatrix4(e.matrixWorld),this.union(Br)}let s=e.children;for(let r=0,a=s.length;r<a;r++)this.expandByObject(s[r],t);return this}containsPoint(e){return e.x>=this.min.x&&e.x<=this.max.x&&e.y>=this.min.y&&e.y<=this.max.y&&e.z>=this.min.z&&e.z<=this.max.z}containsBox(e){return this.min.x<=e.min.x&&e.max.x<=this.max.x&&this.min.y<=e.min.y&&e.max.y<=this.max.y&&this.min.z<=e.min.z&&e.max.z<=this.max.z}getParameter(e,t){return t.set((e.x-this.min.x)/(this.max.x-this.min.x),(e.y-this.min.y)/(this.max.y-this.min.y),(e.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(e){return e.max.x>=this.min.x&&e.min.x<=this.max.x&&e.max.y>=this.min.y&&e.min.y<=this.max.y&&e.max.z>=this.min.z&&e.min.z<=this.max.z}intersectsSphere(e){return this.clampPoint(e.center,mn),mn.distanceToSquared(e.center)<=e.radius*e.radius}intersectsPlane(e){let t,n;return e.normal.x>0?(t=e.normal.x*this.min.x,n=e.normal.x*this.max.x):(t=e.normal.x*this.max.x,n=e.normal.x*this.min.x),e.normal.y>0?(t+=e.normal.y*this.min.y,n+=e.normal.y*this.max.y):(t+=e.normal.y*this.max.y,n+=e.normal.y*this.min.y),e.normal.z>0?(t+=e.normal.z*this.min.z,n+=e.normal.z*this.max.z):(t+=e.normal.z*this.max.z,n+=e.normal.z*this.min.z),t<=-e.constant&&n>=-e.constant}intersectsTriangle(e){if(this.isEmpty())return!1;this.getCenter(Bs),kr.subVectors(this.max,Bs),Qi.subVectors(e.a,Bs),es.subVectors(e.b,Bs),ts.subVectors(e.c,Bs),ci.subVectors(es,Qi),li.subVectors(ts,es),wi.subVectors(Qi,ts);let t=[0,-ci.z,ci.y,0,-li.z,li.y,0,-wi.z,wi.y,ci.z,0,-ci.x,li.z,0,-li.x,wi.z,0,-wi.x,-ci.y,ci.x,0,-li.y,li.x,0,-wi.y,wi.x,0];return!rc(t,Qi,es,ts,kr)||(t=[1,0,0,0,1,0,0,0,1],!rc(t,Qi,es,ts,kr))?!1:(Vr.crossVectors(ci,li),t=[Vr.x,Vr.y,Vr.z],rc(t,Qi,es,ts,kr))}clampPoint(e,t){return t.copy(e).clamp(this.min,this.max)}distanceToPoint(e){return this.clampPoint(e,mn).distanceTo(e)}getBoundingSphere(e){return this.isEmpty()?e.makeEmpty():(this.getCenter(e.center),e.radius=this.getSize(mn).length()*.5),e}intersect(e){return this.min.max(e.min),this.max.min(e.max),this.isEmpty()&&this.makeEmpty(),this}union(e){return this.min.min(e.min),this.max.max(e.max),this}applyMatrix4(e){return this.isEmpty()?this:(Wn[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(e),Wn[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(e),Wn[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(e),Wn[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(e),Wn[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(e),Wn[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(e),Wn[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(e),Wn[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(e),this.setFromPoints(Wn),this)}translate(e){return this.min.add(e),this.max.add(e),this}equals(e){return e.min.equals(this.min)&&e.max.equals(this.max)}toJSON(){return{min:this.min.toArray(),max:this.max.toArray()}}fromJSON(e){return this.min.fromArray(e.min),this.max.fromArray(e.max),this}},Wn=[new O,new O,new O,new O,new O,new O,new O,new O],mn=new O,Br=new en,Qi=new O,es=new O,ts=new O,ci=new O,li=new O,wi=new O,Bs=new O,kr=new O,Vr=new O,Ti=new O;function rc(i,e,t,n,s){for(let r=0,a=i.length-3;r<=a;r+=3){Ti.fromArray(i,r);let o=s.x*Math.abs(Ti.x)+s.y*Math.abs(Ti.y)+s.z*Math.abs(Ti.z),c=e.dot(Ti),l=t.dot(Ti),h=n.dot(Ti);if(Math.max(-Math.max(c,l,h),Math.min(c,l,h))>o)return!1}return!0}var _t=new O,Gr=new Oe,id=0,bt=class extends Pn{constructor(e,t,n=!1){if(super(),Array.isArray(e))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,Object.defineProperty(this,"id",{value:id++}),this.name="",this.array=e,this.itemSize=t,this.count=e!==void 0?e.length/t:0,this.normalized=n,this.usage=Kc,this.updateRanges=[],this.gpuType=nn,this.version=0}onUploadCallback(){}set needsUpdate(e){e===!0&&this.version++}setUsage(e){return this.usage=e,this}addUpdateRange(e,t){this.updateRanges.push({start:e,count:t})}clearUpdateRanges(){this.updateRanges.length=0}copy(e){return this.name=e.name,this.array=new e.array.constructor(e.array),this.itemSize=e.itemSize,this.count=e.count,this.normalized=e.normalized,this.usage=e.usage,this.gpuType=e.gpuType,this}copyAt(e,t,n){e*=this.itemSize,n*=t.itemSize;for(let s=0,r=this.itemSize;s<r;s++)this.array[e+s]=t.array[n+s];return this}copyArray(e){return this.array.set(e),this}applyMatrix3(e){if(this.itemSize===2)for(let t=0,n=this.count;t<n;t++)Gr.fromBufferAttribute(this,t),Gr.applyMatrix3(e),this.setXY(t,Gr.x,Gr.y);else if(this.itemSize===3)for(let t=0,n=this.count;t<n;t++)_t.fromBufferAttribute(this,t),_t.applyMatrix3(e),this.setXYZ(t,_t.x,_t.y,_t.z);return this}applyMatrix4(e){for(let t=0,n=this.count;t<n;t++)_t.fromBufferAttribute(this,t),_t.applyMatrix4(e),this.setXYZ(t,_t.x,_t.y,_t.z);return this}applyNormalMatrix(e){for(let t=0,n=this.count;t<n;t++)_t.fromBufferAttribute(this,t),_t.applyNormalMatrix(e),this.setXYZ(t,_t.x,_t.y,_t.z);return this}transformDirection(e){for(let t=0,n=this.count;t<n;t++)_t.fromBufferAttribute(this,t),_t.transformDirection(e),this.setXYZ(t,_t.x,_t.y,_t.z);return this}set(e,t=0){return this.array.set(e,t),this}getComponent(e,t){let n=this.array[e*this.itemSize+t];return this.normalized&&(n=gn(n,this.array)),n}setComponent(e,t,n){return this.normalized&&(n=Qe(n,this.array)),this.array[e*this.itemSize+t]=n,this}getX(e){let t=this.array[e*this.itemSize];return this.normalized&&(t=gn(t,this.array)),t}setX(e,t){return this.normalized&&(t=Qe(t,this.array)),this.array[e*this.itemSize]=t,this}getY(e){let t=this.array[e*this.itemSize+1];return this.normalized&&(t=gn(t,this.array)),t}setY(e,t){return this.normalized&&(t=Qe(t,this.array)),this.array[e*this.itemSize+1]=t,this}getZ(e){let t=this.array[e*this.itemSize+2];return this.normalized&&(t=gn(t,this.array)),t}setZ(e,t){return this.normalized&&(t=Qe(t,this.array)),this.array[e*this.itemSize+2]=t,this}getW(e){let t=this.array[e*this.itemSize+3];return this.normalized&&(t=gn(t,this.array)),t}setW(e,t){return this.normalized&&(t=Qe(t,this.array)),this.array[e*this.itemSize+3]=t,this}setXY(e,t,n){return e*=this.itemSize,this.normalized&&(t=Qe(t,this.array),n=Qe(n,this.array)),this.array[e+0]=t,this.array[e+1]=n,this}setXYZ(e,t,n,s){return e*=this.itemSize,this.normalized&&(t=Qe(t,this.array),n=Qe(n,this.array),s=Qe(s,this.array)),this.array[e+0]=t,this.array[e+1]=n,this.array[e+2]=s,this}setXYZW(e,t,n,s,r){return e*=this.itemSize,this.normalized&&(t=Qe(t,this.array),n=Qe(n,this.array),s=Qe(s,this.array),r=Qe(r,this.array)),this.array[e+0]=t,this.array[e+1]=n,this.array[e+2]=s,this.array[e+3]=r,this}onUpload(e){return this.onUploadCallback=e,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){let e={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return e.name=this.name,e.usage=this.usage,e.gpuType=this.gpuType,e}dispose(){this.dispatchEvent({type:"dispose"})}};var Qs=class extends bt{constructor(e,t,n){super(new Uint16Array(e),t,n)}};var er=class extends bt{constructor(e,t,n){super(new Uint32Array(e),t,n)}};var Bt=class extends bt{constructor(e,t,n){super(new Float32Array(e),t,n)}},sd=new en,ks=new O,ac=new O,Xt=class{constructor(e=new O,t=-1){this.isSphere=!0,this.center=e,this.radius=t}set(e,t){return this.center.copy(e),this.radius=t,this}setFromPoints(e,t){let n=this.center;t!==void 0?n.copy(t):sd.setFromPoints(e).getCenter(n);let s=0;for(let r=0,a=e.length;r<a;r++)s=Math.max(s,n.distanceToSquared(e[r]));return this.radius=Math.sqrt(s),this}copy(e){return this.center.copy(e.center),this.radius=e.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(e){return e.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(e){return e.distanceTo(this.center)-this.radius}intersectsSphere(e){let t=this.radius+e.radius;return e.center.distanceToSquared(this.center)<=t*t}intersectsBox(e){return e.intersectsSphere(this)}intersectsPlane(e){return Math.abs(e.distanceToPoint(this.center))<=this.radius}clampPoint(e,t){let n=this.center.distanceToSquared(e);return t.copy(e),n>this.radius*this.radius&&(t.sub(this.center).normalize(),t.multiplyScalar(this.radius).add(this.center)),t}getBoundingBox(e){return this.isEmpty()?(e.makeEmpty(),e):(e.set(this.center,this.center),e.expandByScalar(this.radius),e)}applyMatrix4(e){return this.center.applyMatrix4(e),this.radius=this.radius*e.getMaxScaleOnAxis(),this}translate(e){return this.center.add(e),this}expandByPoint(e){if(this.isEmpty())return this.center.copy(e),this.radius=0,this;ks.subVectors(e,this.center);let t=ks.lengthSq();if(t>this.radius*this.radius){let n=Math.sqrt(t),s=(n-this.radius)*.5;this.center.addScaledVector(ks,s/n),this.radius+=s}return this}union(e){return e.isEmpty()?this:this.isEmpty()?(this.copy(e),this):(this.center.equals(e.center)===!0?this.radius=Math.max(this.radius,e.radius):(ac.subVectors(e.center,this.center).setLength(e.radius),this.expandByPoint(ks.copy(e.center).add(ac)),this.expandByPoint(ks.copy(e.center).sub(ac))),this)}equals(e){return e.center.equals(this.center)&&e.radius===this.radius}clone(){return new this.constructor().copy(this)}toJSON(){return{radius:this.radius,center:this.center.toArray()}}fromJSON(e){return this.radius=e.radius,this.center.fromArray(e.center),this}},rd=0,on=new Ne,oc=new ut,ns=new O,$t=new en,Vs=new en,At=new O,Nt=class i extends Pn{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:rd++}),this.uuid=xn(),this.name="",this.type="BufferGeometry",this.index=null,this.indirect=null,this.indirectOffset=0,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={},this._transformed=!1}getIndex(){return this.index}setIndex(e){return Array.isArray(e)?this.index=new(Cf(e)?er:Qs)(e,1):this.index=e,this}setIndirect(e,t=0){return this.indirect=e,this.indirectOffset=t,this}getIndirect(){return this.indirect}getAttribute(e){return this.attributes[e]}setAttribute(e,t){return this.attributes[e]=t,this}deleteAttribute(e){return delete this.attributes[e],this}hasAttribute(e){return this.attributes[e]!==void 0}addGroup(e,t,n=0){this.groups.push({start:e,count:t,materialIndex:n})}clearGroups(){this.groups=[]}setDrawRange(e,t){this.drawRange.start=e,this.drawRange.count=t}applyMatrix4(e){let t=this.attributes.position;t!==void 0&&(t.applyMatrix4(e),t.needsUpdate=!0);let n=this.attributes.normal;if(n!==void 0){let r=new Ie().getNormalMatrix(e);n.applyNormalMatrix(r),n.needsUpdate=!0}let s=this.attributes.tangent;return s!==void 0&&(s.transformDirection(e),s.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this._transformed=!0,this}applyQuaternion(e){return on.makeRotationFromQuaternion(e),this.applyMatrix4(on),this}rotateX(e){return on.makeRotationX(e),this.applyMatrix4(on),this}rotateY(e){return on.makeRotationY(e),this.applyMatrix4(on),this}rotateZ(e){return on.makeRotationZ(e),this.applyMatrix4(on),this}translate(e,t,n){return on.makeTranslation(e,t,n),this.applyMatrix4(on),this}scale(e,t,n){return on.makeScale(e,t,n),this.applyMatrix4(on),this}lookAt(e){return oc.lookAt(e),oc.updateMatrix(),this.applyMatrix4(oc.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(ns).negate(),this.translate(ns.x,ns.y,ns.z),this}setFromPoints(e){let t=this.getAttribute("position");if(t===void 0){let n=[];for(let s=0,r=e.length;s<r;s++){let a=e[s];n.push(a.x,a.y,a.z||0)}this.setAttribute("position",new Bt(n,3))}else{let n=Math.min(e.length,t.count);for(let s=0;s<n;s++){let r=e[s];t.setXYZ(s,r.x,r.y,r.z||0)}e.length>t.count&&be("BufferGeometry: Buffer size too small for points data. Use .dispose() and create a new geometry."),t.needsUpdate=!0}return this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new en);let e=this.attributes.position,t=this.morphAttributes.position;if(e&&e.isGLBufferAttribute){ze("BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box.",this),this.boundingBox.set(new O(-1/0,-1/0,-1/0),new O(1/0,1/0,1/0));return}if(e!==void 0){if(this.boundingBox.setFromBufferAttribute(e),t)for(let n=0,s=t.length;n<s;n++){let r=t[n];$t.setFromBufferAttribute(r),this.morphTargetsRelative?(At.addVectors(this.boundingBox.min,$t.min),this.boundingBox.expandByPoint(At),At.addVectors(this.boundingBox.max,$t.max),this.boundingBox.expandByPoint(At)):(this.boundingBox.expandByPoint($t.min),this.boundingBox.expandByPoint($t.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&ze('BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new Xt);let e=this.attributes.position,t=this.morphAttributes.position;if(e&&e.isGLBufferAttribute){ze("BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere.",this),this.boundingSphere.set(new O,1/0);return}if(e){let n=this.boundingSphere.center;if($t.setFromBufferAttribute(e),t)for(let r=0,a=t.length;r<a;r++){let o=t[r];Vs.setFromBufferAttribute(o),this.morphTargetsRelative?(At.addVectors($t.min,Vs.min),$t.expandByPoint(At),At.addVectors($t.max,Vs.max),$t.expandByPoint(At)):($t.expandByPoint(Vs.min),$t.expandByPoint(Vs.max))}$t.getCenter(n);let s=0;for(let r=0,a=e.count;r<a;r++)At.fromBufferAttribute(e,r),s=Math.max(s,n.distanceToSquared(At));if(t)for(let r=0,a=t.length;r<a;r++){let o=t[r],c=this.morphTargetsRelative;for(let l=0,h=o.count;l<h;l++)At.fromBufferAttribute(o,l),c&&(ns.fromBufferAttribute(e,l),At.add(ns)),s=Math.max(s,n.distanceToSquared(At))}this.boundingSphere.radius=Math.sqrt(s),isNaN(this.boundingSphere.radius)&&ze('BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){let e=this.index,t=this.attributes;if(e===null||t.position===void 0||t.normal===void 0||t.uv===void 0){ze("BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}let n=t.position,s=t.normal,r=t.uv,a=this.getAttribute("tangent");(a===void 0||a.count!==n.count)&&(a=new bt(new Float32Array(4*n.count),4),this.setAttribute("tangent",a));let o=[],c=[];for(let _=0;_<n.count;_++)o[_]=new O,c[_]=new O;let l=new O,h=new O,f=new O,u=new Oe,d=new Oe,g=new Oe,y=new O,m=new O;function p(_,E,P){l.fromBufferAttribute(n,_),h.fromBufferAttribute(n,E),f.fromBufferAttribute(n,P),u.fromBufferAttribute(r,_),d.fromBufferAttribute(r,E),g.fromBufferAttribute(r,P),h.sub(l),f.sub(l),d.sub(u),g.sub(u);let N=1/(d.x*g.y-g.x*d.y);isFinite(N)&&(y.copy(h).multiplyScalar(g.y).addScaledVector(f,-d.y).multiplyScalar(N),m.copy(f).multiplyScalar(d.x).addScaledVector(h,-g.x).multiplyScalar(N),o[_].add(y),o[E].add(y),o[P].add(y),c[_].add(m),c[E].add(m),c[P].add(m))}let T=this.groups;T.length===0&&(T=[{start:0,count:e.count}]);for(let _=0,E=T.length;_<E;++_){let P=T[_],N=P.start,k=P.count;for(let H=N,L=N+k;H<L;H+=3)p(e.getX(H+0),e.getX(H+1),e.getX(H+2))}let R=new O,v=new O,b=new O,S=new O;function A(_){b.fromBufferAttribute(s,_),S.copy(b);let E=o[_];R.copy(E),R.sub(b.multiplyScalar(b.dot(E))).normalize(),v.crossVectors(S,E);let N=v.dot(c[_])<0?-1:1;a.setXYZW(_,R.x,R.y,R.z,N)}for(let _=0,E=T.length;_<E;++_){let P=T[_],N=P.start,k=P.count;for(let H=N,L=N+k;H<L;H+=3)A(e.getX(H+0)),A(e.getX(H+1)),A(e.getX(H+2))}this._transformed=!0}computeVertexNormals(){let e=this.index,t=this.getAttribute("position");if(t!==void 0){let n=this.getAttribute("normal");if(n===void 0||n.count!==t.count)n=new bt(new Float32Array(t.count*3),3),this.setAttribute("normal",n);else for(let u=0,d=n.count;u<d;u++)n.setXYZ(u,0,0,0);let s=new O,r=new O,a=new O,o=new O,c=new O,l=new O,h=new O,f=new O;if(e)for(let u=0,d=e.count;u<d;u+=3){let g=e.getX(u+0),y=e.getX(u+1),m=e.getX(u+2);s.fromBufferAttribute(t,g),r.fromBufferAttribute(t,y),a.fromBufferAttribute(t,m),h.subVectors(a,r),f.subVectors(s,r),h.cross(f),o.fromBufferAttribute(n,g),c.fromBufferAttribute(n,y),l.fromBufferAttribute(n,m),o.add(h),c.add(h),l.add(h),n.setXYZ(g,o.x,o.y,o.z),n.setXYZ(y,c.x,c.y,c.z),n.setXYZ(m,l.x,l.y,l.z)}else for(let u=0,d=t.count;u<d;u+=3)s.fromBufferAttribute(t,u+0),r.fromBufferAttribute(t,u+1),a.fromBufferAttribute(t,u+2),h.subVectors(a,r),f.subVectors(s,r),h.cross(f),n.setXYZ(u+0,h.x,h.y,h.z),n.setXYZ(u+1,h.x,h.y,h.z),n.setXYZ(u+2,h.x,h.y,h.z);this.normalizeNormals(),n.needsUpdate=!0}}normalizeNormals(){let e=this.attributes.normal;for(let t=0,n=e.count;t<n;t++)At.fromBufferAttribute(e,t),At.normalize(),e.setXYZ(t,At.x,At.y,At.z)}toNonIndexed(){function e(o,c){let l=o.array,h=o.itemSize,f=o.normalized,u=new l.constructor(c.length*h),d=0,g=0;for(let y=0,m=c.length;y<m;y++){o.isInterleavedBufferAttribute?d=c[y]*o.data.stride+o.offset:d=c[y]*h;for(let p=0;p<h;p++)u[g++]=l[d++]}return new bt(u,h,f)}if(this.index===null)return be("BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;let t=new i,n=this.index.array,s=this.attributes;for(let o in s){let c=s[o],l=e(c,n);t.setAttribute(o,l)}let r=this.morphAttributes;for(let o in r){let c=[],l=r[o];for(let h=0,f=l.length;h<f;h++){let u=l[h],d=e(u,n);c.push(d)}t.morphAttributes[o]=c}t.morphTargetsRelative=this.morphTargetsRelative;let a=this.groups;for(let o=0,c=a.length;o<c;o++){let l=a[o];t.addGroup(l.start,l.count,l.materialIndex)}return t}toJSON(){let e={metadata:{version:4.7,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(e.uuid=this.uuid,e.type=this.parameters!==void 0&&this._transformed===!0?"BufferGeometry":this.type,e.name=this.name,Object.keys(this.userData).length>0&&(e.userData=this.userData),this.parameters!==void 0&&this._transformed!==!0){let c=this.parameters;for(let l in c)c[l]!==void 0&&(e[l]=c[l]);return e}e.data={attributes:{}};let t=this.index;t!==null&&(e.data.index={type:t.array.constructor.name,array:Array.prototype.slice.call(t.array)});let n=this.attributes;for(let c in n){let l=n[c];e.data.attributes[c]=l.toJSON(e.data)}let s={},r=!1;for(let c in this.morphAttributes){let l=this.morphAttributes[c],h=[];for(let f=0,u=l.length;f<u;f++){let d=l[f];h.push(d.toJSON(e.data))}h.length>0&&(s[c]=h,r=!0)}r&&(e.data.morphAttributes=s,e.data.morphTargetsRelative=this.morphTargetsRelative);let a=this.groups;a.length>0&&(e.data.groups=JSON.parse(JSON.stringify(a)));let o=this.boundingSphere;return o!==null&&(e.data.boundingSphere=o.toJSON()),e}clone(){return new this.constructor().copy(this)}copy(e){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;let t={};this.name=e.name;let n=e.index;n!==null&&this.setIndex(n.clone());let s=e.attributes;for(let l in s){let h=s[l];this.setAttribute(l,h.clone(t))}let r=e.morphAttributes;for(let l in r){let h=[],f=r[l];for(let u=0,d=f.length;u<d;u++)h.push(f[u].clone(t));this.morphAttributes[l]=h}this.morphTargetsRelative=e.morphTargetsRelative;let a=e.groups;for(let l=0,h=a.length;l<h;l++){let f=a[l];this.addGroup(f.start,f.count,f.materialIndex)}let o=e.boundingBox;o!==null&&(this.boundingBox=o.clone());let c=e.boundingSphere;return c!==null&&(this.boundingSphere=c.clone()),this.drawRange.start=e.drawRange.start,this.drawRange.count=e.drawRange.count,this.userData=e.userData,this._transformed=e._transformed,this}dispose(){this.dispatchEvent({type:"dispose"})}},ms=class{constructor(e,t){this.isInterleavedBuffer=!0,this.array=e,this.stride=t,this.count=e!==void 0?e.length/t:0,this.usage=Kc,this.updateRanges=[],this.version=0,this.uuid=xn()}onUploadCallback(){}set needsUpdate(e){e===!0&&this.version++}setUsage(e){return this.usage=e,this}addUpdateRange(e,t){this.updateRanges.push({start:e,count:t})}clearUpdateRanges(){this.updateRanges.length=0}copy(e){return this.array=new e.array.constructor(e.array),this.count=e.count,this.stride=e.stride,this.usage=e.usage,this}copyAt(e,t,n){e*=this.stride,n*=t.stride;for(let s=0,r=this.stride;s<r;s++)this.array[e+s]=t.array[n+s];return this}set(e,t=0){return this.array.set(e,t),this}clone(e){e.arrayBuffers===void 0&&(e.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=xn()),e.arrayBuffers[this.array.buffer._uuid]===void 0&&(e.arrayBuffers[this.array.buffer._uuid]=this.array.slice(0).buffer);let t=new this.array.constructor(e.arrayBuffers[this.array.buffer._uuid]),n=new this.constructor(t,this.stride);return n.setUsage(this.usage),n}onUpload(e){return this.onUploadCallback=e,this}toJSON(e){e.arrayBuffers===void 0&&(e.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=xn()),e.arrayBuffers[this.array.buffer._uuid]===void 0&&(e.arrayBuffers[this.array.buffer._uuid]=Array.from(new Uint32Array(this.array.buffer)));let t={uuid:this.uuid,buffer:this.array.buffer._uuid,type:this.array.constructor.name,stride:this.stride};return t.usage=this.usage,t}},Ft=new O,Ms=class i{constructor(e,t,n,s=!1){this.isInterleavedBufferAttribute=!0,this.name="",this.data=e,this.itemSize=t,this.offset=n,this.normalized=s}get count(){return this.data.count}get array(){return this.data.array}set needsUpdate(e){this.data.needsUpdate=e}applyMatrix4(e){for(let t=0,n=this.data.count;t<n;t++)Ft.fromBufferAttribute(this,t),Ft.applyMatrix4(e),this.setXYZ(t,Ft.x,Ft.y,Ft.z);return this}applyNormalMatrix(e){for(let t=0,n=this.count;t<n;t++)Ft.fromBufferAttribute(this,t),Ft.applyNormalMatrix(e),this.setXYZ(t,Ft.x,Ft.y,Ft.z);return this}transformDirection(e){for(let t=0,n=this.count;t<n;t++)Ft.fromBufferAttribute(this,t),Ft.transformDirection(e),this.setXYZ(t,Ft.x,Ft.y,Ft.z);return this}getComponent(e,t){let n=this.array[e*this.data.stride+this.offset+t];return this.normalized&&(n=gn(n,this.array)),n}setComponent(e,t,n){return this.normalized&&(n=Qe(n,this.array)),this.data.array[e*this.data.stride+this.offset+t]=n,this}setX(e,t){return this.normalized&&(t=Qe(t,this.array)),this.data.array[e*this.data.stride+this.offset]=t,this}setY(e,t){return this.normalized&&(t=Qe(t,this.array)),this.data.array[e*this.data.stride+this.offset+1]=t,this}setZ(e,t){return this.normalized&&(t=Qe(t,this.array)),this.data.array[e*this.data.stride+this.offset+2]=t,this}setW(e,t){return this.normalized&&(t=Qe(t,this.array)),this.data.array[e*this.data.stride+this.offset+3]=t,this}getX(e){let t=this.data.array[e*this.data.stride+this.offset];return this.normalized&&(t=gn(t,this.array)),t}getY(e){let t=this.data.array[e*this.data.stride+this.offset+1];return this.normalized&&(t=gn(t,this.array)),t}getZ(e){let t=this.data.array[e*this.data.stride+this.offset+2];return this.normalized&&(t=gn(t,this.array)),t}getW(e){let t=this.data.array[e*this.data.stride+this.offset+3];return this.normalized&&(t=gn(t,this.array)),t}setXY(e,t,n){return e=e*this.data.stride+this.offset,this.normalized&&(t=Qe(t,this.array),n=Qe(n,this.array)),this.data.array[e+0]=t,this.data.array[e+1]=n,this}setXYZ(e,t,n,s){return e=e*this.data.stride+this.offset,this.normalized&&(t=Qe(t,this.array),n=Qe(n,this.array),s=Qe(s,this.array)),this.data.array[e+0]=t,this.data.array[e+1]=n,this.data.array[e+2]=s,this}setXYZW(e,t,n,s,r){return e=e*this.data.stride+this.offset,this.normalized&&(t=Qe(t,this.array),n=Qe(n,this.array),s=Qe(s,this.array),r=Qe(r,this.array)),this.data.array[e+0]=t,this.data.array[e+1]=n,this.data.array[e+2]=s,this.data.array[e+3]=r,this}clone(e){if(e===void 0){Ks("InterleavedBufferAttribute.clone(): Cloning an interleaved buffer attribute will de-interleave buffer data.");let t=[];for(let n=0;n<this.count;n++){let s=n*this.data.stride+this.offset;for(let r=0;r<this.itemSize;r++)t.push(this.data.array[s+r])}return new bt(new this.array.constructor(t),this.itemSize,this.normalized)}else return e.interleavedBuffers===void 0&&(e.interleavedBuffers={}),e.interleavedBuffers[this.data.uuid]===void 0&&(e.interleavedBuffers[this.data.uuid]=this.data.clone(e)),new i(e.interleavedBuffers[this.data.uuid],this.itemSize,this.offset,this.normalized)}toJSON(e){if(e===void 0){Ks("InterleavedBufferAttribute.toJSON(): Serializing an interleaved buffer attribute will de-interleave buffer data.");let t=[];for(let n=0;n<this.count;n++){let s=n*this.data.stride+this.offset;for(let r=0;r<this.itemSize;r++)t.push(this.data.array[s+r])}return{itemSize:this.itemSize,type:this.array.constructor.name,array:t,normalized:this.normalized}}else return e.interleavedBuffers===void 0&&(e.interleavedBuffers={}),e.interleavedBuffers[this.data.uuid]===void 0&&(e.interleavedBuffers[this.data.uuid]=this.data.toJSON(e)),{isInterleavedBufferAttribute:!0,itemSize:this.itemSize,data:this.data.uuid,offset:this.offset,normalized:this.normalized}}},cc=new O,ad=new O,od=new Ie,Mn=class{constructor(e=new O(1,0,0),t=0){this.isPlane=!0,this.normal=e,this.constant=t}set(e,t){return this.normal.copy(e),this.constant=t,this}setComponents(e,t,n,s){return this.normal.set(e,t,n),this.constant=s,this}setFromNormalAndCoplanarPoint(e,t){return this.normal.copy(e),this.constant=-t.dot(this.normal),this}setFromCoplanarPoints(e,t,n){let s=cc.subVectors(n,t).cross(ad.subVectors(e,t)).normalize();return this.setFromNormalAndCoplanarPoint(s,e),this}copy(e){return this.normal.copy(e.normal),this.constant=e.constant,this}normalize(){let e=1/this.normal.length();return this.normal.multiplyScalar(e),this.constant*=e,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(e){return this.normal.dot(e)+this.constant}distanceToSphere(e){return this.distanceToPoint(e.center)-e.radius}projectPoint(e,t){return t.copy(e).addScaledVector(this.normal,-this.distanceToPoint(e))}intersectLine(e,t,n=!0){let s=e.delta(cc),r=this.normal.dot(s);if(r===0)return this.distanceToPoint(e.start)===0?t.copy(e.start):null;let a=-(e.start.dot(this.normal)+this.constant)/r;return n===!0&&(a<0||a>1)?null:t.copy(e.start).addScaledVector(s,a)}intersectsLine(e){let t=this.distanceToPoint(e.start),n=this.distanceToPoint(e.end);return t<0&&n>0||n<0&&t>0}intersectsBox(e){return e.intersectsPlane(this)}intersectsSphere(e){return e.intersectsPlane(this)}coplanarPoint(e){return e.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(e,t){let n=t||od.getNormalMatrix(e),s=this.coplanarPoint(cc).applyMatrix4(e),r=this.normal.applyMatrix3(n).normalize();return this.constant=-s.dot(r),this}translate(e){return this.constant-=e.dot(this.normal),this}equals(e){return e.normal.equals(this.normal)&&e.constant===this.constant}clone(){return new this.constructor().copy(this)}toJSON(){return{normal:this.normal.toArray(),constant:this.constant}}fromJSON(e){return this.normal.fromArray(e.normal),this.constant=e.constant,this}},cd=0,Vt=class extends Pn{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:cd++}),this.uuid=xn(),this.name="",this.type="Material",this.blending=Es,this.side=On,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=Pc,this.blendDst=Lc,this.blendEquation=Ui,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new Ce(0,0,0),this.blendAlpha=0,this.depthFunc=cs,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=Mu,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=ca,this.stencilZFail=ca,this.stencilZPass=ca,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.allowOverride=!0,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(e){this._alphaTest>0!=e>0&&this.version++,this._alphaTest=e}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(e){if(e!==void 0)for(let t in e){let n=e[t];if(n===void 0){be(`Material: parameter '${t}' has value of undefined.`);continue}let s=this[t];if(s===void 0){be(`Material: '${t}' is not a property of THREE.${this.type}.`);continue}s&&s.isColor?s.set(n):s&&s.isVector2&&n&&n.isVector2||s&&s.isEuler&&n&&n.isEuler||s&&s.isVector3&&n&&n.isVector3?s.copy(n):this[t]=n}}toJSON(e){let t=e===void 0||typeof e=="string";t&&(e={textures:{},images:{}});let n={metadata:{version:4.7,type:"Material",generator:"Material.toJSON"}};n.uuid=this.uuid,n.type=this.type,n.blending=this.blending,n.side=this.side,n.shadowSide=this.shadowSide,n.vertexColors=this.vertexColors,n.opacity=this.opacity,n.transparent=this.transparent,n.blendSrc=this.blendSrc,n.blendDst=this.blendDst,n.blendEquation=this.blendEquation,n.blendSrcAlpha=this.blendSrcAlpha,n.blendDstAlpha=this.blendDstAlpha,n.blendEquationAlpha=this.blendEquationAlpha,n.blendColor=this.blendColor.getHex(),n.blendAlpha=this.blendAlpha,n.depthFunc=this.depthFunc,n.depthTest=this.depthTest,n.depthWrite=this.depthWrite,n.colorWrite=this.colorWrite,n.clipIntersection=this.clipIntersection,n.clipShadows=this.clipShadows,n.stencilWriteMask=this.stencilWriteMask,n.stencilFunc=this.stencilFunc,n.stencilRef=this.stencilRef,n.stencilFuncMask=this.stencilFuncMask,n.stencilFail=this.stencilFail,n.stencilZFail=this.stencilZFail,n.stencilZPass=this.stencilZPass,n.stencilWrite=this.stencilWrite,n.polygonOffset=this.polygonOffset,n.polygonOffsetFactor=this.polygonOffsetFactor,n.polygonOffsetUnits=this.polygonOffsetUnits,n.dithering=this.dithering,n.alphaTest=this.alphaTest,n.alphaHash=this.alphaHash,n.alphaToCoverage=this.alphaToCoverage,n.premultipliedAlpha=this.premultipliedAlpha,n.forceSinglePass=this.forceSinglePass,n.allowOverride=this.allowOverride,n.visible=this.visible,n.toneMapped=this.toneMapped,n.name=this.name,this.color&&this.color.isColor&&(n.color=this.color.getHex()),this.roughness!==void 0&&(n.roughness=this.roughness),this.metalness!==void 0&&(n.metalness=this.metalness),this.sheen!==void 0&&(n.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(n.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(n.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(n.emissive=this.emissive.getHex()),this.emissiveIntensity!==void 0&&(n.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(n.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(n.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(n.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(n.shininess=this.shininess),this.clearcoat!==void 0&&(n.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(n.clearcoatRoughness=this.clearcoatRoughness),this.clearcoatMap&&this.clearcoatMap.isTexture&&(n.clearcoatMap=this.clearcoatMap.toJSON(e).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(n.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(e).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(n.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(e).uuid,n.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.sheenColorMap&&this.sheenColorMap.isTexture&&(n.sheenColorMap=this.sheenColorMap.toJSON(e).uuid),this.sheenRoughnessMap&&this.sheenRoughnessMap.isTexture&&(n.sheenRoughnessMap=this.sheenRoughnessMap.toJSON(e).uuid),this.dispersion!==void 0&&(n.dispersion=this.dispersion),this.retroreflectivity!==void 0&&(n.retroreflectivity=this.retroreflectivity),this.iridescence!==void 0&&(n.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(n.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessRange!==void 0&&(n.iridescenceThicknessRange=this.iridescenceThicknessRange),this.iridescenceMap&&this.iridescenceMap.isTexture&&(n.iridescenceMap=this.iridescenceMap.toJSON(e).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(n.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(e).uuid),this.anisotropy!==void 0&&(n.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(n.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(n.anisotropyMap=this.anisotropyMap.toJSON(e).uuid),this.map&&this.map.isTexture&&(n.map=this.map.toJSON(e).uuid),this.matcap&&this.matcap.isTexture&&(n.matcap=this.matcap.toJSON(e).uuid),this.alphaMap&&this.alphaMap.isTexture&&(n.alphaMap=this.alphaMap.toJSON(e).uuid),this.lightMap&&this.lightMap.isTexture&&(n.lightMap=this.lightMap.toJSON(e).uuid,n.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(n.aoMap=this.aoMap.toJSON(e).uuid,n.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(n.bumpMap=this.bumpMap.toJSON(e).uuid,n.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(n.normalMap=this.normalMap.toJSON(e).uuid,n.normalMapType=this.normalMapType,n.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(n.displacementMap=this.displacementMap.toJSON(e).uuid,n.displacementScale=this.displacementScale,n.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(n.roughnessMap=this.roughnessMap.toJSON(e).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(n.metalnessMap=this.metalnessMap.toJSON(e).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(n.emissiveMap=this.emissiveMap.toJSON(e).uuid),this.specularMap&&this.specularMap.isTexture&&(n.specularMap=this.specularMap.toJSON(e).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(n.specularIntensityMap=this.specularIntensityMap.toJSON(e).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(n.specularColorMap=this.specularColorMap.toJSON(e).uuid),this.envMap&&this.envMap.isTexture&&(n.envMap=this.envMap.toJSON(e).uuid,this.combine!==void 0&&(n.combine=this.combine)),this.envMapRotation!==void 0&&(n.envMapRotation=this.envMapRotation.toArray()),this.envMapIntensity!==void 0&&(n.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(n.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(n.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(n.gradientMap=this.gradientMap.toJSON(e).uuid),this.transmission!==void 0&&(n.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(n.transmissionMap=this.transmissionMap.toJSON(e).uuid),this.thickness!==void 0&&(n.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(n.thicknessMap=this.thicknessMap.toJSON(e).uuid),this.attenuationDistance!==void 0&&(n.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(n.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(n.size=this.size),this.sizeAttenuation!==void 0&&(n.sizeAttenuation=this.sizeAttenuation),Array.isArray(this.clippingPlanes)&&this.clippingPlanes.length>0&&(n.clippingPlanes=this.clippingPlanes.map(r=>r.toJSON())),this.rotation!==void 0&&(n.rotation=this.rotation),this.depthPacking!==void 0&&(n.depthPacking=this.depthPacking),this.linewidth!==void 0&&(n.linewidth=this.linewidth),this.linecap!==void 0&&(n.linecap=this.linecap),this.linejoin!==void 0&&(n.linejoin=this.linejoin),this.dashSize!==void 0&&(n.dashSize=this.dashSize),this.gapSize!==void 0&&(n.gapSize=this.gapSize),this.scale!==void 0&&(n.scale=this.scale),this.wireframe!==void 0&&(n.wireframe=this.wireframe),this.wireframeLinewidth!==void 0&&(n.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!==void 0&&(n.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!==void 0&&(n.wireframeLinejoin=this.wireframeLinejoin),this.flatShading!==void 0&&(n.flatShading=this.flatShading),this.fog!==void 0&&(n.fog=this.fog),Object.keys(this.userData).length>0&&(n.userData=this.userData);function s(r){let a=[];for(let o in r){let c=r[o];delete c.metadata,a.push(c)}return a}if(t){let r=s(e.textures),a=s(e.images);r.length>0&&(n.textures=r),a.length>0&&(n.images=a)}return n}fromJSON(e,t){if(e.uuid!==void 0&&(this.uuid=e.uuid),e.name!==void 0&&(this.name=e.name),e.color!==void 0&&this.color!==void 0&&this.color.setHex(e.color),e.roughness!==void 0&&(this.roughness=e.roughness),e.metalness!==void 0&&(this.metalness=e.metalness),e.sheen!==void 0&&(this.sheen=e.sheen),e.sheenColor!==void 0&&(this.sheenColor=new Ce().setHex(e.sheenColor)),e.sheenRoughness!==void 0&&(this.sheenRoughness=e.sheenRoughness),e.emissive!==void 0&&this.emissive!==void 0&&this.emissive.setHex(e.emissive),e.specular!==void 0&&this.specular!==void 0&&this.specular.setHex(e.specular),e.specularIntensity!==void 0&&(this.specularIntensity=e.specularIntensity),e.specularColor!==void 0&&this.specularColor!==void 0&&this.specularColor.setHex(e.specularColor),e.shininess!==void 0&&(this.shininess=e.shininess),e.clearcoat!==void 0&&(this.clearcoat=e.clearcoat),e.clearcoatRoughness!==void 0&&(this.clearcoatRoughness=e.clearcoatRoughness),e.dispersion!==void 0&&(this.dispersion=e.dispersion),e.retroreflectivity!==void 0&&(this.retroreflectivity=e.retroreflectivity),e.iridescence!==void 0&&(this.iridescence=e.iridescence),e.iridescenceIOR!==void 0&&(this.iridescenceIOR=e.iridescenceIOR),e.iridescenceThicknessRange!==void 0&&(this.iridescenceThicknessRange=e.iridescenceThicknessRange),e.transmission!==void 0&&(this.transmission=e.transmission),e.thickness!==void 0&&(this.thickness=e.thickness),e.attenuationDistance!==void 0&&(this.attenuationDistance=e.attenuationDistance),e.attenuationColor!==void 0&&this.attenuationColor!==void 0&&this.attenuationColor.setHex(e.attenuationColor),e.anisotropy!==void 0&&(this.anisotropy=e.anisotropy),e.anisotropyRotation!==void 0&&(this.anisotropyRotation=e.anisotropyRotation),e.fog!==void 0&&(this.fog=e.fog),e.flatShading!==void 0&&(this.flatShading=e.flatShading),e.blending!==void 0&&(this.blending=e.blending),e.combine!==void 0&&(this.combine=e.combine),e.side!==void 0&&(this.side=e.side),e.shadowSide!==void 0&&(this.shadowSide=e.shadowSide),e.opacity!==void 0&&(this.opacity=e.opacity),e.transparent!==void 0&&(this.transparent=e.transparent),e.alphaTest!==void 0&&(this.alphaTest=e.alphaTest),e.alphaHash!==void 0&&(this.alphaHash=e.alphaHash),e.depthFunc!==void 0&&(this.depthFunc=e.depthFunc),e.depthTest!==void 0&&(this.depthTest=e.depthTest),e.depthWrite!==void 0&&(this.depthWrite=e.depthWrite),e.colorWrite!==void 0&&(this.colorWrite=e.colorWrite),e.clippingPlanes!==void 0&&(this.clippingPlanes=e.clippingPlanes.map(n=>new Mn().fromJSON(n))),e.clipIntersection!==void 0&&(this.clipIntersection=e.clipIntersection),e.clipShadows!==void 0&&(this.clipShadows=e.clipShadows),e.depthPacking!==void 0&&(this.depthPacking=e.depthPacking),e.blendSrc!==void 0&&(this.blendSrc=e.blendSrc),e.blendDst!==void 0&&(this.blendDst=e.blendDst),e.blendEquation!==void 0&&(this.blendEquation=e.blendEquation),e.blendSrcAlpha!==void 0&&(this.blendSrcAlpha=e.blendSrcAlpha),e.blendDstAlpha!==void 0&&(this.blendDstAlpha=e.blendDstAlpha),e.blendEquationAlpha!==void 0&&(this.blendEquationAlpha=e.blendEquationAlpha),e.blendColor!==void 0&&this.blendColor!==void 0&&this.blendColor.setHex(e.blendColor),e.blendAlpha!==void 0&&(this.blendAlpha=e.blendAlpha),e.stencilWriteMask!==void 0&&(this.stencilWriteMask=e.stencilWriteMask),e.stencilFunc!==void 0&&(this.stencilFunc=e.stencilFunc),e.stencilRef!==void 0&&(this.stencilRef=e.stencilRef),e.stencilFuncMask!==void 0&&(this.stencilFuncMask=e.stencilFuncMask),e.stencilFail!==void 0&&(this.stencilFail=e.stencilFail),e.stencilZFail!==void 0&&(this.stencilZFail=e.stencilZFail),e.stencilZPass!==void 0&&(this.stencilZPass=e.stencilZPass),e.stencilWrite!==void 0&&(this.stencilWrite=e.stencilWrite),e.wireframe!==void 0&&(this.wireframe=e.wireframe),e.wireframeLinewidth!==void 0&&(this.wireframeLinewidth=e.wireframeLinewidth),e.wireframeLinecap!==void 0&&(this.wireframeLinecap=e.wireframeLinecap),e.wireframeLinejoin!==void 0&&(this.wireframeLinejoin=e.wireframeLinejoin),e.rotation!==void 0&&(this.rotation=e.rotation),e.linewidth!==void 0&&(this.linewidth=e.linewidth),e.linecap!==void 0&&(this.linecap=e.linecap),e.linejoin!==void 0&&(this.linejoin=e.linejoin),e.dashSize!==void 0&&(this.dashSize=e.dashSize),e.gapSize!==void 0&&(this.gapSize=e.gapSize),e.scale!==void 0&&(this.scale=e.scale),e.polygonOffset!==void 0&&(this.polygonOffset=e.polygonOffset),e.polygonOffsetFactor!==void 0&&(this.polygonOffsetFactor=e.polygonOffsetFactor),e.polygonOffsetUnits!==void 0&&(this.polygonOffsetUnits=e.polygonOffsetUnits),e.dithering!==void 0&&(this.dithering=e.dithering),e.alphaToCoverage!==void 0&&(this.alphaToCoverage=e.alphaToCoverage),e.premultipliedAlpha!==void 0&&(this.premultipliedAlpha=e.premultipliedAlpha),e.forceSinglePass!==void 0&&(this.forceSinglePass=e.forceSinglePass),e.allowOverride!==void 0&&(this.allowOverride=e.allowOverride),e.visible!==void 0&&(this.visible=e.visible),e.toneMapped!==void 0&&(this.toneMapped=e.toneMapped),e.userData!==void 0&&(this.userData=e.userData),e.vertexColors!==void 0&&(typeof e.vertexColors=="number"?this.vertexColors=e.vertexColors>0:this.vertexColors=e.vertexColors),e.size!==void 0&&(this.size=e.size),e.sizeAttenuation!==void 0&&(this.sizeAttenuation=e.sizeAttenuation),e.map!==void 0&&(this.map=t[e.map]||null),e.matcap!==void 0&&(this.matcap=t[e.matcap]||null),e.alphaMap!==void 0&&(this.alphaMap=t[e.alphaMap]||null),e.bumpMap!==void 0&&(this.bumpMap=t[e.bumpMap]||null),e.bumpScale!==void 0&&(this.bumpScale=e.bumpScale),e.normalMap!==void 0&&(this.normalMap=t[e.normalMap]||null),e.normalMapType!==void 0&&(this.normalMapType=e.normalMapType),e.normalScale!==void 0){let n=e.normalScale;Array.isArray(n)===!1&&(n=[n,n]),this.normalScale=new Oe().fromArray(n)}return e.displacementMap!==void 0&&(this.displacementMap=t[e.displacementMap]||null),e.displacementScale!==void 0&&(this.displacementScale=e.displacementScale),e.displacementBias!==void 0&&(this.displacementBias=e.displacementBias),e.roughnessMap!==void 0&&(this.roughnessMap=t[e.roughnessMap]||null),e.metalnessMap!==void 0&&(this.metalnessMap=t[e.metalnessMap]||null),e.emissiveMap!==void 0&&(this.emissiveMap=t[e.emissiveMap]||null),e.emissiveIntensity!==void 0&&(this.emissiveIntensity=e.emissiveIntensity),e.specularMap!==void 0&&(this.specularMap=t[e.specularMap]||null),e.specularIntensityMap!==void 0&&(this.specularIntensityMap=t[e.specularIntensityMap]||null),e.specularColorMap!==void 0&&(this.specularColorMap=t[e.specularColorMap]||null),e.envMap!==void 0&&(this.envMap=t[e.envMap]||null),e.envMapRotation!==void 0&&this.envMapRotation.fromArray(e.envMapRotation),e.envMapIntensity!==void 0&&(this.envMapIntensity=e.envMapIntensity),e.reflectivity!==void 0&&(this.reflectivity=e.reflectivity),e.refractionRatio!==void 0&&(this.refractionRatio=e.refractionRatio),e.lightMap!==void 0&&(this.lightMap=t[e.lightMap]||null),e.lightMapIntensity!==void 0&&(this.lightMapIntensity=e.lightMapIntensity),e.aoMap!==void 0&&(this.aoMap=t[e.aoMap]||null),e.aoMapIntensity!==void 0&&(this.aoMapIntensity=e.aoMapIntensity),e.gradientMap!==void 0&&(this.gradientMap=t[e.gradientMap]||null),e.clearcoatMap!==void 0&&(this.clearcoatMap=t[e.clearcoatMap]||null),e.clearcoatRoughnessMap!==void 0&&(this.clearcoatRoughnessMap=t[e.clearcoatRoughnessMap]||null),e.clearcoatNormalMap!==void 0&&(this.clearcoatNormalMap=t[e.clearcoatNormalMap]||null),e.clearcoatNormalScale!==void 0&&(this.clearcoatNormalScale=new Oe().fromArray(e.clearcoatNormalScale)),e.iridescenceMap!==void 0&&(this.iridescenceMap=t[e.iridescenceMap]||null),e.iridescenceThicknessMap!==void 0&&(this.iridescenceThicknessMap=t[e.iridescenceThicknessMap]||null),e.transmissionMap!==void 0&&(this.transmissionMap=t[e.transmissionMap]||null),e.thicknessMap!==void 0&&(this.thicknessMap=t[e.thicknessMap]||null),e.anisotropyMap!==void 0&&(this.anisotropyMap=t[e.anisotropyMap]||null),e.sheenColorMap!==void 0&&(this.sheenColorMap=t[e.sheenColorMap]||null),e.sheenRoughnessMap!==void 0&&(this.sheenRoughnessMap=t[e.sheenRoughnessMap]||null),this}clone(){return new this.constructor().copy(this)}copy(e){this.name=e.name,this.blending=e.blending,this.side=e.side,this.vertexColors=e.vertexColors,this.opacity=e.opacity,this.transparent=e.transparent,this.blendSrc=e.blendSrc,this.blendDst=e.blendDst,this.blendEquation=e.blendEquation,this.blendSrcAlpha=e.blendSrcAlpha,this.blendDstAlpha=e.blendDstAlpha,this.blendEquationAlpha=e.blendEquationAlpha,this.blendColor.copy(e.blendColor),this.blendAlpha=e.blendAlpha,this.depthFunc=e.depthFunc,this.depthTest=e.depthTest,this.depthWrite=e.depthWrite,this.stencilWriteMask=e.stencilWriteMask,this.stencilFunc=e.stencilFunc,this.stencilRef=e.stencilRef,this.stencilFuncMask=e.stencilFuncMask,this.stencilFail=e.stencilFail,this.stencilZFail=e.stencilZFail,this.stencilZPass=e.stencilZPass,this.stencilWrite=e.stencilWrite;let t=e.clippingPlanes,n=null;if(t!==null){let s=t.length;n=new Array(s);for(let r=0;r!==s;++r)n[r]=t[r].clone()}return this.clippingPlanes=n,this.clipIntersection=e.clipIntersection,this.clipShadows=e.clipShadows,this.shadowSide=e.shadowSide,this.colorWrite=e.colorWrite,this.precision=e.precision,this.polygonOffset=e.polygonOffset,this.polygonOffsetFactor=e.polygonOffsetFactor,this.polygonOffsetUnits=e.polygonOffsetUnits,this.dithering=e.dithering,this.alphaTest=e.alphaTest,this.alphaHash=e.alphaHash,this.alphaToCoverage=e.alphaToCoverage,this.premultipliedAlpha=e.premultipliedAlpha,this.forceSinglePass=e.forceSinglePass,this.allowOverride=e.allowOverride,this.visible=e.visible,this.toneMapped=e.toneMapped,this.userData=JSON.parse(JSON.stringify(e.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(e){e===!0&&this.version++}};var Xn=new O,lc=new O,Hr=new O,Wr=new O,Pi=class{constructor(e=new O,t=new O(0,0,-1)){this.origin=e,this.direction=t}set(e,t){return this.origin.copy(e),this.direction.copy(t),this}copy(e){return this.origin.copy(e.origin),this.direction.copy(e.direction),this}at(e,t){return t.copy(this.origin).addScaledVector(this.direction,e)}lookAt(e){return this.direction.copy(e).sub(this.origin).normalize(),this}recast(e){return this.origin.copy(this.at(e,Xn)),this}closestPointToPoint(e,t){t.subVectors(e,this.origin);let n=t.dot(this.direction);return n<0?t.copy(this.origin):t.copy(this.origin).addScaledVector(this.direction,n)}distanceToPoint(e){return Math.sqrt(this.distanceSqToPoint(e))}distanceSqToPoint(e){let t=Xn.subVectors(e,this.origin).dot(this.direction);return t<0?this.origin.distanceToSquared(e):(Xn.copy(this.origin).addScaledVector(this.direction,t),Xn.distanceToSquared(e))}distanceSqToSegment(e,t,n,s){lc.copy(e).add(t).multiplyScalar(.5),Hr.copy(t).sub(e).normalize(),Wr.copy(this.origin).sub(lc);let r=e.distanceTo(t)*.5,a=-this.direction.dot(Hr),o=Wr.dot(this.direction),c=-Wr.dot(Hr),l=Wr.lengthSq(),h=Math.abs(1-a*a),f,u,d,g;if(h>0)if(f=a*c-o,u=a*o-c,g=r*h,f>=0)if(u>=-g)if(u<=g){let y=1/h;f*=y,u*=y,d=f*(f+a*u+2*o)+u*(a*f+u+2*c)+l}else u=r,f=Math.max(0,-(a*u+o)),d=-f*f+u*(u+2*c)+l;else u=-r,f=Math.max(0,-(a*u+o)),d=-f*f+u*(u+2*c)+l;else u<=-g?(f=Math.max(0,-(-a*r+o)),u=f>0?-r:Math.min(Math.max(-r,-c),r),d=-f*f+u*(u+2*c)+l):u<=g?(f=0,u=Math.min(Math.max(-r,-c),r),d=u*(u+2*c)+l):(f=Math.max(0,-(a*r+o)),u=f>0?r:Math.min(Math.max(-r,-c),r),d=-f*f+u*(u+2*c)+l);else u=a>0?-r:r,f=Math.max(0,-(a*u+o)),d=-f*f+u*(u+2*c)+l;return n&&n.copy(this.origin).addScaledVector(this.direction,f),s&&s.copy(lc).addScaledVector(Hr,u),d}intersectSphere(e,t){if(e.radius<0)return null;Xn.subVectors(e.center,this.origin);let n=Xn.dot(this.direction),s=Xn.dot(Xn)-n*n,r=e.radius*e.radius;if(s>r)return null;let a=Math.sqrt(r-s),o=n-a,c=n+a;return c<0?null:o<0?this.at(c,t):this.at(o,t)}intersectsSphere(e){return e.radius<0?!1:this.distanceSqToPoint(e.center)<=e.radius*e.radius}distanceToPlane(e){let t=e.normal.dot(this.direction);if(t===0)return e.distanceToPoint(this.origin)===0?0:null;let n=-(this.origin.dot(e.normal)+e.constant)/t;return n>=0?n:null}intersectPlane(e,t){let n=this.distanceToPlane(e);return n===null?null:this.at(n,t)}intersectsPlane(e){let t=e.distanceToPoint(this.origin);return t===0||e.normal.dot(this.direction)*t<0}intersectBox(e,t){let n,s,r,a,o,c,l=1/this.direction.x,h=1/this.direction.y,f=1/this.direction.z,u=this.origin;return l>=0?(n=(e.min.x-u.x)*l,s=(e.max.x-u.x)*l):(n=(e.max.x-u.x)*l,s=(e.min.x-u.x)*l),h>=0?(r=(e.min.y-u.y)*h,a=(e.max.y-u.y)*h):(r=(e.max.y-u.y)*h,a=(e.min.y-u.y)*h),n>a||r>s||((r>n||isNaN(n))&&(n=r),(a<s||isNaN(s))&&(s=a),f>=0?(o=(e.min.z-u.z)*f,c=(e.max.z-u.z)*f):(o=(e.max.z-u.z)*f,c=(e.min.z-u.z)*f),n>c||o>s)||((o>n||n!==n)&&(n=o),(c<s||s!==s)&&(s=c),s<0)?null:this.at(n>=0?n:s,t)}intersectsBox(e){return this.intersectBox(e,Xn)!==null}intersectTriangle(e,t,n,s,r){let a=this.origin,o=this.direction,c=o.x,l=o.y,h=o.z,f=e.x-a.x,u=e.y-a.y,d=e.z-a.z,g=t.x-a.x,y=t.y-a.y,m=t.z-a.z,p=n.x-a.x,T=n.y-a.y,R=n.z-a.z,v=Math.abs(c),b=Math.abs(l),S=Math.abs(h),A,_,E,P,N,k,H,L,V,K,Z,ne;if(v>=b&&v>=S?(E=c,k=f,V=g,ne=p,c>=0?(A=l,_=h,P=u,N=d,H=y,L=m,K=T,Z=R):(A=h,_=l,P=d,N=u,H=m,L=y,K=R,Z=T)):b>=S?(E=l,k=u,V=y,ne=T,l>=0?(A=h,_=c,P=d,N=f,H=m,L=g,K=R,Z=p):(A=c,_=h,P=f,N=d,H=g,L=m,K=p,Z=R)):(E=h,k=d,V=m,ne=R,h>=0?(A=c,_=l,P=f,N=u,H=g,L=y,K=p,Z=T):(A=l,_=c,P=u,N=f,H=y,L=g,K=T,Z=p)),E===0)return null;let X=A/E,Q=_/E,te=1/E,Ae=P-X*k,Te=N-Q*k,st=H-X*V,Xe=L-Q*V,Ze=K-X*ne,q=Z-Q*ne,j=Ze*Xe-q*st,ge=Ae*q-Te*Ze,Pe=st*Te-Xe*Ae;if(s){if(j<0||ge<0||Pe<0)return null}else if((j<0||ge<0||Pe<0)&&(j>0||ge>0||Pe>0))return null;let me=j+ge+Pe;if(me===0)return null;let Be=te*(j*k+ge*V+Pe*ne);return(me>0?Be<0:Be>0)?null:this.at(Be/me,r)}applyMatrix4(e){return this.origin.applyMatrix4(e),this.direction.transformDirection(e),this}equals(e){return e.origin.equals(this.origin)&&e.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}},yn=class extends Vt{constructor(e){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new Ce(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Ln,this.combine=Da,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.specularMap=e.specularMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.envMapRotation.copy(e.envMapRotation),this.combine=e.combine,this.reflectivity=e.reflectivity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.fog=e.fog,this}},xh=new Ne,Ei=new Pi,Xr=new Xt,yh=new O,qr=new O,Yr=new O,Zr=new O,hc=new O,Kr=new O,vh=new O,Jr=new O,Ct=class extends ut{constructor(e=new Nt,t=new yn){super(),this.isMesh=!0,this.type="Mesh",this.geometry=e,this.material=t,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.count=1,this.updateMorphTargets()}copy(e,t){return super.copy(e,t),e.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=e.morphTargetInfluences.slice()),e.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},e.morphTargetDictionary)),this.material=Array.isArray(e.material)?e.material.slice():e.material,this.geometry=e.geometry,this}updateMorphTargets(){let t=this.geometry.morphAttributes,n=Object.keys(t);if(n.length>0){let s=t[n[0]];if(s!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,a=s.length;r<a;r++){let o=s[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[o]=r}}}}getVertexPosition(e,t){let n=this.geometry,s=n.attributes.position,r=n.morphAttributes.position,a=n.morphTargetsRelative;t.fromBufferAttribute(s,e);let o=this.morphTargetInfluences;if(r&&o){Kr.set(0,0,0);for(let c=0,l=r.length;c<l;c++){let h=o[c],f=r[c];h!==0&&(hc.fromBufferAttribute(f,e),a?Kr.addScaledVector(hc,h):Kr.addScaledVector(hc.sub(t),h))}t.add(Kr)}return t}intersectsFrustum(e){return e.intersectsObject(this)}raycast(e,t){let n=this.geometry,s=this.material,r=this.matrixWorld;s!==void 0&&(n.boundingSphere===null&&n.computeBoundingSphere(),Xr.copy(n.boundingSphere),Xr.applyMatrix4(r),Ei.copy(e.ray).recast(e.near),!(Xr.containsPoint(Ei.origin)===!1&&(Ei.intersectSphere(Xr,yh)===null||Ei.origin.distanceToSquared(yh)>(e.far-e.near)**2))&&(xh.copy(r).invert(),Ei.copy(e.ray).applyMatrix4(xh),!(n.boundingBox!==null&&Ei.intersectsBox(n.boundingBox)===!1)&&this._computeIntersections(e,t,Ei)))}_computeIntersections(e,t,n){let s,r=this.geometry,a=this.material,o=r.index,c=r.attributes.position,l=r.attributes.uv,h=r.attributes.uv1,f=r.attributes.normal,u=r.groups,d=r.drawRange;if(o!==null)if(Array.isArray(a))for(let g=0,y=u.length;g<y;g++){let m=u[g],p=a[m.materialIndex],T=Math.max(m.start,d.start),R=Math.min(o.count,Math.min(m.start+m.count,d.start+d.count));for(let v=T,b=R;v<b;v+=3){let S=o.getX(v),A=o.getX(v+1),_=o.getX(v+2);s=$r(this,p,e,n,l,h,f,S,A,_),s&&(s.faceIndex=Math.floor(v/3),s.face.materialIndex=m.materialIndex,t.push(s))}}else{let g=Math.max(0,d.start),y=Math.min(o.count,d.start+d.count);for(let m=g,p=y;m<p;m+=3){let T=o.getX(m),R=o.getX(m+1),v=o.getX(m+2);s=$r(this,a,e,n,l,h,f,T,R,v),s&&(s.faceIndex=Math.floor(m/3),t.push(s))}}else if(c!==void 0)if(Array.isArray(a))for(let g=0,y=u.length;g<y;g++){let m=u[g],p=a[m.materialIndex],T=Math.max(m.start,d.start),R=Math.min(c.count,Math.min(m.start+m.count,d.start+d.count));for(let v=T,b=R;v<b;v+=3){let S=v,A=v+1,_=v+2;s=$r(this,p,e,n,l,h,f,S,A,_),s&&(s.faceIndex=Math.floor(v/3),s.face.materialIndex=m.materialIndex,t.push(s))}}else{let g=Math.max(0,d.start),y=Math.min(c.count,d.start+d.count);for(let m=g,p=y;m<p;m+=3){let T=m,R=m+1,v=m+2;s=$r(this,a,e,n,l,h,f,T,R,v),s&&(s.faceIndex=Math.floor(m/3),t.push(s))}}}};function ld(i,e,t,n,s,r,a,o){let c;if(e.side===Gt?c=n.intersectTriangle(a,r,s,!0,o):c=n.intersectTriangle(s,r,a,e.side===On,o),c===null)return null;Jr.copy(o),Jr.applyMatrix4(i.matrixWorld);let l=t.ray.origin.distanceTo(Jr);return l<t.near||l>t.far?null:{distance:l,point:Jr.clone(),object:i}}function $r(i,e,t,n,s,r,a,o,c,l){i.getVertexPosition(o,qr),i.getVertexPosition(c,Yr),i.getVertexPosition(l,Zr);let h=ld(i,e,t,n,qr,Yr,Zr,vh);if(h){let f=new O;fi.getBarycoord(vh,qr,Yr,Zr,f),s&&(h.uv=fi.getInterpolatedAttribute(s,o,c,l,f,new Oe)),r&&(h.uv1=fi.getInterpolatedAttribute(r,o,c,l,f,new Oe)),a&&(h.normal=fi.getInterpolatedAttribute(a,o,c,l,f,new O),h.normal.dot(n.direction)>0&&h.normal.multiplyScalar(-1));let u={a:o,b:c,c:l,normal:new O,materialIndex:0};fi.getNormal(qr,Yr,Zr,u.normal),h.face=u,h.barycoord=f}return h}var Gs=new et,bh=new et,Sh=new et,hd=new et,wh=new Ne,jr=new O,uc=new Xt,Th=new Ne,fc=new Pi,tr=class extends Ct{constructor(e,t){super(e,t),this.isSkinnedMesh=!0,this.type="SkinnedMesh",this.bindMode=Mc,this.bindMatrix=new Ne,this.bindMatrixInverse=new Ne,this.boundingBox=null,this.boundingSphere=null}computeBoundingBox(){let e=this.geometry;this.boundingBox===null&&(this.boundingBox=new en),this.boundingBox.makeEmpty();let t=e.getAttribute("position");for(let n=0;n<t.count;n++)this.getVertexPosition(n,jr),this.boundingBox.expandByPoint(jr)}computeBoundingSphere(){let e=this.geometry;this.boundingSphere===null&&(this.boundingSphere=new Xt),this.boundingSphere.makeEmpty();let t=e.getAttribute("position");for(let n=0;n<t.count;n++)this.getVertexPosition(n,jr),this.boundingSphere.expandByPoint(jr)}copy(e,t){return super.copy(e,t),this.bindMode=e.bindMode,this.bindMatrix.copy(e.bindMatrix),this.bindMatrixInverse.copy(e.bindMatrixInverse),this.skeleton=e.skeleton,e.boundingBox!==null&&(this.boundingBox=e.boundingBox.clone()),e.boundingSphere!==null&&(this.boundingSphere=e.boundingSphere.clone()),this}raycast(e,t){let n=this.material,s=this.matrixWorld;n!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),uc.copy(this.boundingSphere),uc.applyMatrix4(s),e.ray.intersectsSphere(uc)!==!1&&(Th.copy(s).invert(),fc.copy(e.ray).applyMatrix4(Th),!(this.boundingBox!==null&&fc.intersectsBox(this.boundingBox)===!1)&&this._computeIntersections(e,t,fc)))}getVertexPosition(e,t){return super.getVertexPosition(e,t),this.applyBoneTransform(e,t),t}bind(e,t){this.skeleton=e,t===void 0&&(this.updateMatrixWorld(!0),this.skeleton.calculateInverses(),t=this.matrixWorld),this.bindMatrix.copy(t),this.bindMatrixInverse.copy(t).invert()}pose(){this.skeleton.pose()}normalizeSkinWeights(){let e=new et,t=this.geometry.attributes.skinWeight;for(let n=0,s=t.count;n<s;n++){e.fromBufferAttribute(t,n);let r=1/e.manhattanLength();r!==1/0?e.multiplyScalar(r):e.set(1,0,0,0),t.setXYZW(n,e.x,e.y,e.z,e.w)}}updateMatrixWorld(e){super.updateMatrixWorld(e),this.bindMode===Mc?this.bindMatrixInverse.copy(this.matrixWorld).invert():this.bindMode===fu?this.bindMatrixInverse.copy(this.bindMatrix).invert():be("SkinnedMesh: Unrecognized bindMode: "+this.bindMode)}applyBoneTransform(e,t){let n=this.skeleton,s=this.geometry;bh.fromBufferAttribute(s.attributes.skinIndex,e),Sh.fromBufferAttribute(s.attributes.skinWeight,e),t.isVector4?(Gs.copy(t),t.set(0,0,0,0)):(Gs.set(...t,1),t.set(0,0,0)),Gs.applyMatrix4(this.bindMatrix);for(let r=0;r<4;r++){let a=Sh.getComponent(r);if(a!==0){let o=bh.getComponent(r);wh.multiplyMatrices(n.bones[o].matrixWorld,n.boneInverses[o]),t.addScaledVector(hd.copy(Gs).applyMatrix4(wh),a)}}return t.isVector4&&(t.w=Gs.w),t.applyMatrix4(this.bindMatrixInverse)}},gs=class extends ut{constructor(){super(),this.isBone=!0,this.type="Bone"}},_s=class extends Rt{constructor(e=null,t=1,n=1,s,r,a,o,c,l=dt,h=dt,f,u){super(null,a,o,c,l,h,s,r,f,u),this.isDataTexture=!0,this.image={data:e,width:t,height:n},this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}},Eh=new Ne,ud=new Ne,nr=class i{constructor(e=[],t=[]){this.uuid=xn(),this.bones=e.slice(0),this.boneInverses=t,this.boneMatrices=null,this.boneTexture=null,this.init()}init(){let e=this.bones,t=this.boneInverses;if(this.boneMatrices=new Float32Array(e.length*16),t.length===0)this.calculateInverses();else if(e.length!==t.length){be("Skeleton: Number of inverse bone matrices does not match amount of bones."),this.boneInverses=[];for(let n=0,s=this.bones.length;n<s;n++)this.boneInverses.push(new Ne)}}calculateInverses(){this.boneInverses.length=0;for(let e=0,t=this.bones.length;e<t;e++){let n=new Ne;this.bones[e]&&n.copy(this.bones[e].matrixWorld).invert(),this.boneInverses.push(n)}}pose(){for(let e=0,t=this.bones.length;e<t;e++){let n=this.bones[e];n&&n.matrixWorld.copy(this.boneInverses[e]).invert()}for(let e=0,t=this.bones.length;e<t;e++){let n=this.bones[e];n&&(n.parent&&n.parent.isBone?(n.matrix.copy(n.parent.matrixWorld).invert(),n.matrix.multiply(n.matrixWorld)):n.matrix.copy(n.matrixWorld),n.matrix.decompose(n.position,n.quaternion,n.scale))}}update(){let e=this.bones,t=this.boneInverses,n=this.boneMatrices,s=this.boneTexture;for(let r=0,a=e.length;r<a;r++){let o=e[r]?e[r].matrixWorld:ud;Eh.multiplyMatrices(o,t[r]),Eh.toArray(n,r*16)}s!==null&&(s.needsUpdate=!0)}clone(){return new i(this.bones,this.boneInverses)}computeBoneTexture(){let e=Math.sqrt(this.bones.length*4);e=Math.ceil(e/4)*4,e=Math.max(e,4);let t=new Float32Array(e*e*4);t.set(this.boneMatrices);let n=new _s(t,e,e,sn,nn);return n.needsUpdate=!0,this.boneMatrices=t,this.boneTexture=n,this}getBoneByName(e){for(let t=0,n=this.bones.length;t<n;t++){let s=this.bones[t];if(s.name===e)return s}}dispose(){this.boneTexture!==null&&(this.boneTexture.dispose(),this.boneTexture=null)}fromJSON(e,t){this.uuid=e.uuid;for(let n=0,s=e.bones.length;n<s;n++){let r=e.bones[n],a=t[r];a===void 0&&(be("Skeleton: No bone found with UUID:",r),a=new gs),this.bones.push(a),this.boneInverses.push(new Ne().fromArray(e.boneInverses[n]))}return this.init(),this}toJSON(){let e={metadata:{version:4.7,type:"Skeleton",generator:"Skeleton.toJSON"},bones:[],boneInverses:[]};e.uuid=this.uuid;let t=this.bones,n=this.boneInverses;for(let s=0,r=t.length;s<r;s++){let a=t[s];e.bones.push(a.uuid);let o=n[s];e.boneInverses.push(o.toArray())}return e}},Zn=class extends bt{constructor(e,t,n,s=1){super(e,t,n),this.isInstancedBufferAttribute=!0,this.meshPerAttribute=s}copy(e){return super.copy(e),this.meshPerAttribute=e.meshPerAttribute,this}toJSON(){let e=super.toJSON();return e.meshPerAttribute=this.meshPerAttribute,e.isInstancedBufferAttribute=!0,e}},is=new Ne,Ah=new Ne,Qr=[],Rh=new en,fd=new Ne,Hs=new Ct,Ws=new Xt,ir=class extends Ct{constructor(e,t,n){super(e,t),this.isInstancedMesh=!0,this.instanceMatrix=new Zn(new Float32Array(n*16),16),this.instanceColor=null,this.morphTexture=null,this.count=n,this.boundingBox=null,this.boundingSphere=null;for(let s=0;s<n;s++)this.setMatrixAt(s,fd)}computeBoundingBox(){let e=this.geometry,t=this.count;this.boundingBox===null&&(this.boundingBox=new en),e.boundingBox===null&&e.computeBoundingBox(),this.boundingBox.makeEmpty();for(let n=0;n<t;n++)this.getMatrixAt(n,is),Rh.copy(e.boundingBox).applyMatrix4(is),this.boundingBox.union(Rh)}computeBoundingSphere(){let e=this.geometry,t=this.count;this.boundingSphere===null&&(this.boundingSphere=new Xt),e.boundingSphere===null&&e.computeBoundingSphere(),this.boundingSphere.makeEmpty();for(let n=0;n<t;n++)this.getMatrixAt(n,is),Ws.copy(e.boundingSphere).applyMatrix4(is),this.boundingSphere.union(Ws)}copy(e,t){return super.copy(e,t),this.instanceMatrix.copy(e.instanceMatrix),e.morphTexture!==null&&(this.morphTexture=e.morphTexture.clone()),e.instanceColor!==null&&(this.instanceColor=e.instanceColor.clone()),this.count=e.count,e.boundingBox!==null&&(this.boundingBox=e.boundingBox.clone()),e.boundingSphere!==null&&(this.boundingSphere=e.boundingSphere.clone()),this}getColorAt(e,t){return this.instanceColor===null?t.setRGB(1,1,1):t.fromArray(this.instanceColor.array,e*3)}getMatrixAt(e,t){return t.fromArray(this.instanceMatrix.array,e*16)}getMorphAt(e,t){let n=t.morphTargetInfluences,s=this.morphTexture.source.data.data,r=n.length+1,a=e*r+1;for(let o=0;o<n.length;o++)n[o]=s[a+o]}raycast(e,t){let n=this.matrixWorld,s=this.count;if(Hs.geometry=this.geometry,Hs.material=this.material,Hs.material!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),Ws.copy(this.boundingSphere),Ws.applyMatrix4(n),e.ray.intersectsSphere(Ws)!==!1))for(let r=0;r<s;r++){this.getMatrixAt(r,is),Ah.multiplyMatrices(n,is),Hs.matrixWorld=Ah,Hs.raycast(e,Qr);for(let a=0,o=Qr.length;a<o;a++){let c=Qr[a];c.instanceId=r,c.object=this,t.push(c)}Qr.length=0}}setColorAt(e,t){return this.instanceColor===null&&(this.instanceColor=new Zn(new Float32Array(this.instanceMatrix.count*3).fill(1),3)),t.toArray(this.instanceColor.array,e*3),this}setMatrixAt(e,t){return t.toArray(this.instanceMatrix.array,e*16),this}setMorphAt(e,t){let n=t.morphTargetInfluences,s=n.length+1;this.morphTexture===null&&(this.morphTexture=new _s(new Float32Array(s*this.count),s,this.count,Ga,nn));let r=this.morphTexture.source.data.data,a=0;for(let l=0;l<n.length;l++)a+=n[l];let o=this.geometry.morphTargetsRelative?1:1-a,c=s*e;return r[c]=o,r.set(n,c+1),this}updateMorphTargets(){}dispose(){super.dispose(),this.morphTexture!==null&&(this.morphTexture.dispose(),this.morphTexture=null)}},Ai=new Xt,dd=new Oe(.5,.5),ea=new O,xs=class{constructor(e=new Mn,t=new Mn,n=new Mn,s=new Mn,r=new Mn,a=new Mn){this.planes=[e,t,n,s,r,a]}set(e,t,n,s,r,a){let o=this.planes;return o[0].copy(e),o[1].copy(t),o[2].copy(n),o[3].copy(s),o[4].copy(r),o[5].copy(a),this}copy(e){let t=this.planes;for(let n=0;n<6;n++)t[n].copy(e.planes[n]);return this}setFromProjectionMatrix(e,t=_n,n=!1){let s=this.planes,r=e.elements,a=r[0],o=r[1],c=r[2],l=r[3],h=r[4],f=r[5],u=r[6],d=r[7],g=r[8],y=r[9],m=r[10],p=r[11],T=r[12],R=r[13],v=r[14],b=r[15];if(s[0].setComponents(l-a,d-h,p-g,b-T).normalize(),s[1].setComponents(l+a,d+h,p+g,b+T).normalize(),s[2].setComponents(l+o,d+f,p+y,b+R).normalize(),s[3].setComponents(l-o,d-f,p-y,b-R).normalize(),n)s[4].setComponents(c,u,m,v).normalize(),s[5].setComponents(l-c,d-u,p-m,b-v).normalize();else if(s[4].setComponents(l-c,d-u,p-m,b-v).normalize(),t===_n)s[5].setComponents(l+c,d+u,p+m,b+v).normalize();else if(t===hs)s[5].setComponents(c,u,m,v).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+t);return this}intersectsObject(e){if(e.boundingSphere!==void 0)e.boundingSphere===null&&e.computeBoundingSphere(),Ai.copy(e.boundingSphere).applyMatrix4(e.matrixWorld);else{let t=e.geometry;t.boundingSphere===null&&t.computeBoundingSphere(),Ai.copy(t.boundingSphere).applyMatrix4(e.matrixWorld)}return this.intersectsSphere(Ai)}intersectsSprite(e){Ai.center.set(0,0,0);let t=dd.distanceTo(e.center);return Ai.radius=.7071067811865476+t,Ai.applyMatrix4(e.matrixWorld),this.intersectsSphere(Ai)}intersectsSphere(e){let t=this.planes,n=e.center,s=-e.radius;for(let r=0;r<6;r++)if(t[r].distanceToPoint(n)<s)return!1;return!0}intersectsBox(e){let t=this.planes;for(let n=0;n<6;n++){let s=t[n];if(ea.x=s.normal.x>0?e.max.x:e.min.x,ea.y=s.normal.y>0?e.max.y:e.min.y,ea.z=s.normal.z>0?e.max.z:e.min.z,s.distanceToPoint(ea)<0)return!1}return!0}containsPoint(e){let t=this.planes;for(let n=0;n<6;n++)if(t[n].distanceToPoint(e)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}};var ys=class extends Vt{constructor(e){super(),this.isLineBasicMaterial=!0,this.type="LineBasicMaterial",this.color=new Ce(16777215),this.map=null,this.linewidth=1,this.linecap="round",this.linejoin="round",this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.linewidth=e.linewidth,this.linecap=e.linecap,this.linejoin=e.linejoin,this.fog=e.fog,this}},ya=new O,va=new O,Ch=new Ne,Xs=new Pi,ta=new Xt,dc=new O,zh=new O,Li=class extends ut{constructor(e=new Nt,t=new ys){super(),this.isLine=!0,this.type="Line",this.geometry=e,this.material=t,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.updateMorphTargets()}copy(e,t){return super.copy(e,t),this.material=Array.isArray(e.material)?e.material.slice():e.material,this.geometry=e.geometry,this}computeLineDistances(){let e=this.geometry;if(e.index===null){let t=e.attributes.position,n=[0];for(let s=1,r=t.count;s<r;s++)ya.fromBufferAttribute(t,s-1),va.fromBufferAttribute(t,s),n[s]=n[s-1],n[s]+=ya.distanceTo(va);e.setAttribute("lineDistance",new Bt(n,1))}else be("Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}intersectsFrustum(e){return e.intersectsObject(this)}raycast(e,t){let n=this.geometry,s=this.matrixWorld,r=e.params.Line.threshold,a=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),ta.copy(n.boundingSphere),ta.applyMatrix4(s),ta.radius+=r,e.ray.intersectsSphere(ta)===!1)return;Ch.copy(s).invert(),Xs.copy(e.ray).applyMatrix4(Ch);let o=r/((this.scale.x+this.scale.y+this.scale.z)/3),c=o*o,l=this.isLineSegments?2:1,h=n.index,u=n.attributes.position;if(h!==null){let d=Math.max(0,a.start),g=Math.min(h.count,a.start+a.count);for(let y=d,m=g-1;y<m;y+=l){let p=h.getX(y),T=h.getX(y+1),R=na(this,e,Xs,c,p,T,y);R&&t.push(R)}if(this.isLineLoop){let y=h.getX(g-1),m=h.getX(d),p=na(this,e,Xs,c,y,m,g-1);p&&t.push(p)}}else{let d=Math.max(0,a.start),g=Math.min(u.count,a.start+a.count);for(let y=d,m=g-1;y<m;y+=l){let p=na(this,e,Xs,c,y,y+1,y);p&&t.push(p)}if(this.isLineLoop){let y=na(this,e,Xs,c,g-1,d,g-1);y&&t.push(y)}}}updateMorphTargets(){let t=this.geometry.morphAttributes,n=Object.keys(t);if(n.length>0){let s=t[n[0]];if(s!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,a=s.length;r<a;r++){let o=s[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[o]=r}}}}};function na(i,e,t,n,s,r,a){let o=i.geometry.attributes.position;if(ya.fromBufferAttribute(o,s),va.fromBufferAttribute(o,r),t.distanceSqToSegment(ya,va,dc,zh)>n)return;dc.applyMatrix4(i.matrixWorld);let l=e.ray.origin.distanceTo(dc);if(!(l<e.near||l>e.far))return{distance:l,point:zh.clone().applyMatrix4(i.matrixWorld),index:a,face:null,faceIndex:null,barycoord:null,object:i}}var Ih=new O,Ph=new O,sr=class extends Li{constructor(e,t){super(e,t),this.isLineSegments=!0,this.type="LineSegments"}computeLineDistances(){let e=this.geometry;if(e.index===null){let t=e.attributes.position,n=[];for(let s=0,r=t.count;s<r;s+=2)Ih.fromBufferAttribute(t,s),Ph.fromBufferAttribute(t,s+1),n[s]=s===0?0:n[s-1],n[s+1]=n[s]+Ih.distanceTo(Ph);e.setAttribute("lineDistance",new Bt(n,1))}else be("LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}},rr=class extends Li{constructor(e,t){super(e,t),this.isLineLoop=!0,this.type="LineLoop"}},vs=class extends Vt{constructor(e){super(),this.isPointsMaterial=!0,this.type="PointsMaterial",this.color=new Ce(16777215),this.map=null,this.alphaMap=null,this.size=1,this.sizeAttenuation=!0,this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.alphaMap=e.alphaMap,this.size=e.size,this.sizeAttenuation=e.sizeAttenuation,this.fog=e.fog,this}},Lh=new Ne,vc=new Pi,ia=new Xt,sa=new O,ar=class extends ut{constructor(e=new Nt,t=new vs){super(),this.isPoints=!0,this.type="Points",this.geometry=e,this.material=t,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.updateMorphTargets()}copy(e,t){return super.copy(e,t),this.material=Array.isArray(e.material)?e.material.slice():e.material,this.geometry=e.geometry,this}intersectsFrustum(e){return e.intersectsObject(this)}raycast(e,t){let n=this.geometry,s=this.matrixWorld,r=e.params.Points.threshold,a=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),ia.copy(n.boundingSphere),ia.applyMatrix4(s),ia.radius+=r,e.ray.intersectsSphere(ia)===!1)return;Lh.copy(s).invert(),vc.copy(e.ray).applyMatrix4(Lh);let o=r/((this.scale.x+this.scale.y+this.scale.z)/3),c=o*o,l=n.index,f=n.attributes.position;if(l!==null){let u=Math.max(0,a.start),d=Math.min(l.count,a.start+a.count);for(let g=u,y=d;g<y;g++){let m=l.getX(g);sa.fromBufferAttribute(f,m),Nh(sa,m,c,s,e,t,this)}}else{let u=Math.max(0,a.start),d=Math.min(f.count,a.start+a.count);for(let g=u,y=d;g<y;g++)sa.fromBufferAttribute(f,g),Nh(sa,g,c,s,e,t,this)}}updateMorphTargets(){let t=this.geometry.morphAttributes,n=Object.keys(t);if(n.length>0){let s=t[n[0]];if(s!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,a=s.length;r<a;r++){let o=s[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[o]=r}}}}};function Nh(i,e,t,n,s,r,a){let o=vc.distanceSqToPoint(i);if(o<t){let c=new O;vc.closestPointToPoint(i,c),c.applyMatrix4(n);let l=s.ray.origin.distanceTo(c);if(l<s.near||l>s.far)return;r.push({distance:l,distanceToRay:Math.sqrt(o),point:c,index:e,face:null,faceIndex:null,barycoord:null,object:a})}}var or=class extends Rt{constructor(e=[],t=gi,n,s,r,a,o,c,l,h){super(e,t,n,s,r,a,o,c,l,h),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(e){this.image=e}};var pi=class extends Rt{constructor(e,t,n=Sn,s,r,a,o=dt,c=dt,l,h=In,f=1){if(h!==In&&h!==_i)throw new Error("THREE.DepthTexture: format must be either THREE.DepthFormat or THREE.DepthStencilFormat");let u={width:e,height:t,depth:f};super(u,s,r,a,o,c,h,n,l),this.isDepthTexture=!0,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(e){return super.copy(e),this.source=new ds(Object.assign({},e.image)),this.compareFunction=e.compareFunction,this}toJSON(e){let t=super.toJSON(e);return t.compareFunction=this.compareFunction,t}},ba=class extends pi{constructor(e,t=Sn,n=gi,s,r,a=dt,o=dt,c,l=In){let h={width:e,height:e,depth:1},f=[h,h,h,h,h,h];super(e,e,t,n,s,r,a,o,c,l),this.image=f,this.isCubeDepthTexture=!0,this.isCubeTexture=!0}get images(){return this.image}set images(e){this.image=e}},cr=class extends Rt{constructor(e=null){super(),this.sourceTexture=e,this.isExternalTexture=!0}copy(e){return super.copy(e),this.sourceTexture=e.sourceTexture,this}},bs=class i extends Nt{constructor(e=1,t=1,n=1,s=1,r=1,a=1){super(),this.type="BoxGeometry",this.parameters={width:e,height:t,depth:n,widthSegments:s,heightSegments:r,depthSegments:a};let o=this;s=Math.floor(s),r=Math.floor(r),a=Math.floor(a);let c=[],l=[],h=[],f=[],u=0,d=0;g("z","y","x",-1,-1,n,t,e,a,r,0),g("z","y","x",1,-1,n,t,-e,a,r,1),g("x","z","y",1,1,e,n,t,s,a,2),g("x","z","y",1,-1,e,n,-t,s,a,3),g("x","y","z",1,-1,e,t,n,s,r,4),g("x","y","z",-1,-1,e,t,-n,s,r,5),this.setIndex(c),this.setAttribute("position",new Bt(l,3)),this.setAttribute("normal",new Bt(h,3)),this.setAttribute("uv",new Bt(f,2));function g(y,m,p,T,R,v,b,S,A,_,E){let P=v/A,N=b/_,k=v/2,H=b/2,L=S/2,V=A+1,K=_+1,Z=0,ne=0,X=new O;for(let Q=0;Q<K;Q++){let te=Q*N-H;for(let Ae=0;Ae<V;Ae++){let Te=Ae*P-k;X[y]=Te*T,X[m]=te*R,X[p]=L,l.push(X.x,X.y,X.z),X[y]=0,X[m]=0,X[p]=S>0?1:-1,h.push(X.x,X.y,X.z),f.push(Ae/A),f.push(1-Q/_),Z+=1}}for(let Q=0;Q<_;Q++)for(let te=0;te<A;te++){let Ae=u+te+V*Q,Te=u+te+V*(Q+1),st=u+(te+1)+V*(Q+1),Xe=u+(te+1)+V*Q;c.push(Ae,Te,Xe),c.push(Te,st,Xe),ne+=6}o.addGroup(d,ne,E),d+=ne,u+=Z}}copy(e){return super.copy(e),this.parameters=Object.assign({},e.parameters),this}static fromJSON(e){return new i(e.width,e.height,e.depth,e.widthSegments,e.heightSegments,e.depthSegments)}};var lr=class i extends Nt{constructor(e=1,t=1,n=1,s=1){super(),this.type="PlaneGeometry",this.parameters={width:e,height:t,widthSegments:n,heightSegments:s};let r=e/2,a=t/2,o=Math.floor(n),c=Math.floor(s),l=o+1,h=c+1,f=e/o,u=t/c,d=[],g=[],y=[],m=[];for(let p=0;p<h;p++){let T=p*u-a;for(let R=0;R<l;R++){let v=R*f-r;g.push(v,-T,0),y.push(0,0,1),m.push(R/o),m.push(1-p/c)}}for(let p=0;p<c;p++)for(let T=0;T<o;T++){let R=T+l*p,v=T+l*(p+1),b=T+1+l*(p+1),S=T+1+l*p;d.push(R,v,S),d.push(v,b,S)}this.setIndex(d),this.setAttribute("position",new Bt(g,3)),this.setAttribute("normal",new Bt(y,3)),this.setAttribute("uv",new Bt(m,2))}copy(e){return super.copy(e),this.parameters=Object.assign({},e.parameters),this}static fromJSON(e){return new i(e.width,e.height,e.widthSegments,e.heightSegments)}};function ki(i){let e={};for(let t in i){e[t]={};for(let n in i[t]){let s=i[t][n];if(Dh(s))s.isRenderTargetTexture?(be("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),e[t][n]=null):e[t][n]=s.clone();else if(Array.isArray(s))if(Dh(s[0])){let r=[];for(let a=0,o=s.length;a<o;a++)r[a]=s[a].clone();e[t][n]=r}else e[t][n]=s.slice();else e[t][n]=s}}return e}function Dt(i){let e={};for(let t=0;t<i.length;t++){let n=ki(i[t]);for(let s in n)e[s]=n[s]}return e}function Dh(i){return i&&(i.isColor||i.isMatrix3||i.isMatrix4||i.isVector2||i.isVector3||i.isVector4||i.isTexture||i.isQuaternion)}function pd(i){let e=[];for(let t=0;t<i.length;t++)e.push(i[t].clone());return e}function jc(i){let e=i.getRenderTarget();return e===null?i.outputColorSpace:e.isXRRenderTarget===!0?e.texture.colorSpace:Fe.workingColorSpace}var Ru={clone:ki,merge:Dt},md=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,Md=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`,tn=class extends Vt{constructor(e){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=md,this.fragmentShader=Md,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={clipCullDistance:!1,multiDraw:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,e!==void 0&&this.setValues(e)}copy(e){return super.copy(e),this.fragmentShader=e.fragmentShader,this.vertexShader=e.vertexShader,this.uniforms=ki(e.uniforms),this.uniformsGroups=pd(e.uniformsGroups),this.defines=Object.assign({},e.defines),this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.fog=e.fog,this.lights=e.lights,this.clipping=e.clipping,this.extensions=Object.assign({},e.extensions),this.glslVersion=e.glslVersion,this.defaultAttributeValues=Object.assign({},e.defaultAttributeValues),this.index0AttributeName=e.index0AttributeName,this.uniformsNeedUpdate=e.uniformsNeedUpdate,this}toJSON(e){let t=super.toJSON(e);t.glslVersion=this.glslVersion,t.uniforms={};for(let s in this.uniforms){let a=this.uniforms[s].value;a&&a.isTexture?t.uniforms[s]={type:"t",value:a.toJSON(e).uuid}:a&&a.isColor?t.uniforms[s]={type:"c",value:a.getHex()}:a&&a.isVector2?t.uniforms[s]={type:"v2",value:a.toArray()}:a&&a.isVector3?t.uniforms[s]={type:"v3",value:a.toArray()}:a&&a.isVector4?t.uniforms[s]={type:"v4",value:a.toArray()}:a&&a.isMatrix3?t.uniforms[s]={type:"m3",value:a.toArray()}:a&&a.isMatrix4?t.uniforms[s]={type:"m4",value:a.toArray()}:t.uniforms[s]={value:a}}Object.keys(this.defines).length>0&&(t.defines=this.defines),t.vertexShader=this.vertexShader,t.fragmentShader=this.fragmentShader,t.lights=this.lights,t.clipping=this.clipping;let n={};for(let s in this.extensions)this.extensions[s]===!0&&(n[s]=!0);return Object.keys(n).length>0&&(t.extensions=n),t}fromJSON(e,t){if(super.fromJSON(e,t),e.uniforms!==void 0)for(let n in e.uniforms){let s=e.uniforms[n];switch(this.uniforms[n]={},s.type){case"t":this.uniforms[n].value=t[s.value]||null;break;case"c":this.uniforms[n].value=new Ce().setHex(s.value);break;case"v2":this.uniforms[n].value=new Oe().fromArray(s.value);break;case"v3":this.uniforms[n].value=new O().fromArray(s.value);break;case"v4":this.uniforms[n].value=new et().fromArray(s.value);break;case"m3":this.uniforms[n].value=new Ie().fromArray(s.value);break;case"m4":this.uniforms[n].value=new Ne().fromArray(s.value);break;default:this.uniforms[n].value=s.value}}if(e.defines!==void 0&&(this.defines=e.defines),e.vertexShader!==void 0&&(this.vertexShader=e.vertexShader),e.fragmentShader!==void 0&&(this.fragmentShader=e.fragmentShader),e.glslVersion!==void 0&&(this.glslVersion=e.glslVersion),e.extensions!==void 0)for(let n in e.extensions)this.extensions[n]=e.extensions[n];return e.lights!==void 0&&(this.lights=e.lights),e.clipping!==void 0&&(this.clipping=e.clipping),this}},Sa=class extends tn{constructor(e){super(e),this.isRawShaderMaterial=!0,this.type="RawShaderMaterial"}},Ni=class extends Vt{constructor(e){super(),this.isMeshStandardMaterial=!0,this.type="MeshStandardMaterial",this.defines={STANDARD:""},this.color=new Ce(16777215),this.roughness=1,this.metalness=0,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new Ce(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Ar,this.normalScale=new Oe(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.roughnessMap=null,this.metalnessMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Ln,this.envMapIntensity=1,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.defines={STANDARD:""},this.color.copy(e.color),this.roughness=e.roughness,this.metalness=e.metalness,this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.emissive.copy(e.emissive),this.emissiveMap=e.emissiveMap,this.emissiveIntensity=e.emissiveIntensity,this.bumpMap=e.bumpMap,this.bumpScale=e.bumpScale,this.normalMap=e.normalMap,this.normalMapType=e.normalMapType,this.normalScale.copy(e.normalScale),this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.roughnessMap=e.roughnessMap,this.metalnessMap=e.metalnessMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.envMapRotation.copy(e.envMapRotation),this.envMapIntensity=e.envMapIntensity,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.flatShading=e.flatShading,this.fog=e.fog,this}},qt=class extends Ni{constructor(e){super(),this.isMeshPhysicalMaterial=!0,this.defines={STANDARD:"",PHYSICAL:""},this.type="MeshPhysicalMaterial",this.anisotropyRotation=0,this.anisotropyMap=null,this.clearcoatMap=null,this.clearcoatRoughness=0,this.clearcoatRoughnessMap=null,this.clearcoatNormalScale=new Oe(1,1),this.clearcoatNormalMap=null,this.ior=1.5,Object.defineProperty(this,"reflectivity",{get:function(){return He(2.5*(this.ior-1)/(this.ior+1),0,1)},set:function(t){this.ior=(1+.4*t)/(1-.4*t)}}),this.iridescenceMap=null,this.iridescenceIOR=1.3,this.iridescenceThicknessRange=[100,400],this.iridescenceThicknessMap=null,this.sheenColor=new Ce(0),this.sheenColorMap=null,this.sheenRoughness=1,this.sheenRoughnessMap=null,this.transmissionMap=null,this.thickness=0,this.thicknessMap=null,this.attenuationDistance=1/0,this.attenuationColor=new Ce(1,1,1),this.specularIntensity=1,this.specularIntensityMap=null,this.specularColor=new Ce(1,1,1),this.specularColorMap=null,this._anisotropy=0,this._clearcoat=0,this._dispersion=0,this._iridescence=0,this._retroreflectivity=0,this._sheen=0,this._transmission=0,this.setValues(e)}get anisotropy(){return this._anisotropy}set anisotropy(e){this._anisotropy>0!=e>0&&this.version++,this._anisotropy=e}get clearcoat(){return this._clearcoat}set clearcoat(e){this._clearcoat>0!=e>0&&this.version++,this._clearcoat=e}get iridescence(){return this._iridescence}set iridescence(e){this._iridescence>0!=e>0&&this.version++,this._iridescence=e}get dispersion(){return this._dispersion}set dispersion(e){this._dispersion>0!=e>0&&this.version++,this._dispersion=e}get retroreflectivity(){return this._retroreflectivity}set retroreflectivity(e){this._retroreflectivity>0!=e>0&&this.version++,this._retroreflectivity=e}get sheen(){return this._sheen}set sheen(e){this._sheen>0!=e>0&&this.version++,this._sheen=e}get transmission(){return this._transmission}set transmission(e){this._transmission>0!=e>0&&this.version++,this._transmission=e}copy(e){return super.copy(e),this.defines={STANDARD:"",PHYSICAL:""},this.anisotropy=e.anisotropy,this.anisotropyRotation=e.anisotropyRotation,this.anisotropyMap=e.anisotropyMap,this.clearcoat=e.clearcoat,this.clearcoatMap=e.clearcoatMap,this.clearcoatRoughness=e.clearcoatRoughness,this.clearcoatRoughnessMap=e.clearcoatRoughnessMap,this.clearcoatNormalMap=e.clearcoatNormalMap,this.clearcoatNormalScale.copy(e.clearcoatNormalScale),this.dispersion=e.dispersion,this.ior=e.ior,this.iridescence=e.iridescence,this.iridescenceMap=e.iridescenceMap,this.iridescenceIOR=e.iridescenceIOR,this.iridescenceThicknessRange=[...e.iridescenceThicknessRange],this.iridescenceThicknessMap=e.iridescenceThicknessMap,this.retroreflectivity=e.retroreflectivity,this.sheen=e.sheen,this.sheenColor.copy(e.sheenColor),this.sheenColorMap=e.sheenColorMap,this.sheenRoughness=e.sheenRoughness,this.sheenRoughnessMap=e.sheenRoughnessMap,this.transmission=e.transmission,this.transmissionMap=e.transmissionMap,this.thickness=e.thickness,this.thicknessMap=e.thicknessMap,this.attenuationDistance=e.attenuationDistance,this.attenuationColor.copy(e.attenuationColor),this.specularIntensity=e.specularIntensity,this.specularIntensityMap=e.specularIntensityMap,this.specularColor.copy(e.specularColor),this.specularColorMap=e.specularColorMap,this}};var ln=class extends Vt{constructor(e){super(),this.isMeshLambertMaterial=!0,this.type="MeshLambertMaterial",this.color=new Ce(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new Ce(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Ar,this.normalScale=new Oe(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Ln,this.combine=Da,this.reflectivity=1,this.envMapIntensity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.emissive.copy(e.emissive),this.emissiveMap=e.emissiveMap,this.emissiveIntensity=e.emissiveIntensity,this.bumpMap=e.bumpMap,this.bumpScale=e.bumpScale,this.normalMap=e.normalMap,this.normalMapType=e.normalMapType,this.normalScale.copy(e.normalScale),this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.specularMap=e.specularMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.envMapRotation.copy(e.envMapRotation),this.combine=e.combine,this.reflectivity=e.reflectivity,this.envMapIntensity=e.envMapIntensity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.flatShading=e.flatShading,this.fog=e.fog,this}},wa=class extends Vt{constructor(e){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=pu,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(e)}copy(e){return super.copy(e),this.depthPacking=e.depthPacking,this.map=e.map,this.alphaMap=e.alphaMap,this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this}},Ta=class extends Vt{constructor(e){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(e)}copy(e){return super.copy(e),this.map=e.map,this.alphaMap=e.alphaMap,this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this}};function ui(i,e){return!i||i.constructor===e?i:typeof e.BYTES_PER_ELEMENT=="number"?new e(i):Array.prototype.slice.call(i)}function la(i){return i!==void 0&&i.inTangents!==void 0&&i.outTangents!==void 0}function gd(i){function e(s,r){return i[s]-i[r]}let t=i.length,n=new Array(t);for(let s=0;s!==t;++s)n[s]=s;return n.sort(e),n}function Oh(i,e,t){let n=i.length,s=new i.constructor(n);for(let r=0,a=0;a!==n;++r){let o=t[r]*e;for(let c=0;c!==e;++c)s[a++]=i[o+c]}return s}function _d(i,e,t,n){let s=1,r=i[0];for(;r!==void 0&&r[n]===void 0;)r=i[s++];if(r===void 0)return;let a=r[n];if(a!==void 0)if(Array.isArray(a))do a=r[n],a!==void 0&&(e.push(r.time),t.push(...a)),r=i[s++];while(r!==void 0);else if(a.toArray!==void 0)do a=r[n],a!==void 0&&(e.push(r.time),a.toArray(t,t.length)),r=i[s++];while(r!==void 0);else do a=r[n],a!==void 0&&(e.push(r.time),t.push(a)),r=i[s++];while(r!==void 0)}var Nn=class{constructor(e,t,n,s){this.parameterPositions=e,this._cachedIndex=0,this.resultBuffer=s!==void 0?s:new t.constructor(n),this.sampleValues=t,this.valueSize=n,this.settings=null,this.DefaultSettings_={}}evaluate(e){let t=this.parameterPositions,n=this._cachedIndex,s=t[n],r=t[n-1];n:{e:{let a;t:{i:if(!(e<s)){for(let o=n+2;;){if(s===void 0){if(e<r)break i;return n=t.length,this._cachedIndex=n,this.copySampleValue_(n-1)}if(n===o)break;if(r=s,s=t[++n],e<s)break e}a=t.length;break t}if(!(e>=r)){let o=t[1];e<o&&(n=2,r=o);for(let c=n-2;;){if(r===void 0)return this._cachedIndex=0,this.copySampleValue_(0);if(n===c)break;if(s=r,r=t[--n-1],e>=r)break e}a=n,n=0;break t}break n}for(;n<a;){let o=n+a>>>1;e<t[o]?a=o:n=o+1}if(s=t[n],r=t[n-1],r===void 0)return this._cachedIndex=0,this.copySampleValue_(0);if(s===void 0)return n=t.length,this._cachedIndex=n,this.copySampleValue_(n-1)}this._cachedIndex=n,this.intervalChanged_(n,r,s)}return this.interpolate_(n,r,e,s)}getSettings_(){return this.settings||this.DefaultSettings_}copySampleValue_(e){let t=this.resultBuffer,n=this.sampleValues,s=this.valueSize,r=e*s;for(let a=0;a!==s;++a)t[a]=n[r+a];return t}interpolate_(){throw new Error("THREE.Interpolant: Call to abstract method.")}intervalChanged_(){}},Ea=class extends Nn{constructor(e,t,n,s){super(e,t,n,s),this._weightPrev=-0,this._offsetPrev=-0,this._weightNext=-0,this._offsetNext=-0,this.DefaultSettings_={endingStart:_c,endingEnd:_c}}intervalChanged_(e,t,n){let s=this.parameterPositions,r=e-2,a=e+1,o=s[r],c=s[a];if(o===void 0)switch(this.getSettings_().endingStart){case xc:r=e,o=2*t-n;break;case yc:r=s.length-2,o=t+s[r]-s[r+1];break;default:r=e,o=n}if(c===void 0)switch(this.getSettings_().endingEnd){case xc:a=e,c=2*n-t;break;case yc:a=1,c=n+s[1]-s[0];break;default:a=e-1,c=t}let l=(n-t)*.5,h=this.valueSize;this._weightPrev=l/(t-o),this._weightNext=l/(c-n),this._offsetPrev=r*h,this._offsetNext=a*h}interpolate_(e,t,n,s){let r=this.resultBuffer,a=this.sampleValues,o=this.valueSize,c=e*o,l=c-o,h=this._offsetPrev,f=this._offsetNext,u=this._weightPrev,d=this._weightNext,g=(n-t)/(s-t),y=g*g,m=y*g,p=-u*m+2*u*y-u*g,T=(1+u)*m+(-1.5-2*u)*y+(-.5+u)*g+1,R=(-1-d)*m+(1.5+d)*y+.5*g,v=d*m-d*y;for(let b=0;b!==o;++b)r[b]=p*a[h+b]+T*a[l+b]+R*a[c+b]+v*a[f+b];return r}},Aa=class extends Nn{constructor(e,t,n,s){super(e,t,n,s)}interpolate_(e,t,n,s){let r=this.resultBuffer,a=this.sampleValues,o=this.valueSize,c=e*o,l=c-o,h=(n-t)/(s-t),f=1-h;for(let u=0;u!==o;++u)r[u]=a[l+u]*f+a[c+u]*h;return r}},Ra=class extends Nn{constructor(e,t,n,s){super(e,t,n,s)}interpolate_(e){return this.copySampleValue_(e-1)}},Ca=class extends Nn{interpolate_(e,t,n,s){let r=this.resultBuffer,a=this.sampleValues,o=this.valueSize,c=e*o,l=c-o,h=this.inTangents,f=this.outTangents;if(!h||!f){let g=(n-t)/(s-t),y=1-g;for(let m=0;m!==o;++m)r[m]=a[l+m]*y+a[c+m]*g;return r}let u=o*2,d=e-1;for(let g=0;g!==o;++g){let y=a[l+g],m=a[c+g],p=d*u+g*2,T=f[p],R=f[p+1],v=e*u+g*2,b=h[v],S=h[v+1],A=yd(n,t,T,b,s);r[g]=Cu(A,y,R,S,m)}return r}};function Cu(i,e,t,n,s){let r=1-i;return r*r*r*e+3*r*r*i*t+3*r*i*i*n+i*i*i*s}function xd(i,e,t,n,s){let r=1-i;return 3*r*r*(t-e)+6*r*i*(n-t)+3*i*i*(s-n)}function yd(i,e,t,n,s){let r=(i-e)/(s-e);for(let a=0;a<8;a++){let o=Cu(r,e,t,n,s)-i;if(Math.abs(o)<1e-10)break;let c=xd(r,e,t,n,s);if(Math.abs(c)<1e-10)break;r=Math.max(0,Math.min(1,r-o/c))}return r}var Yt=class{constructor(e,t,n,s){if(e===void 0)throw new Error("THREE.KeyframeTrack: track name is undefined");if(t===void 0||t.length===0)throw new Error("THREE.KeyframeTrack: no keyframes in track named "+e);this.name=e,this.times=ui(t,this.TimeBufferType),this.values=ui(n,this.ValueBufferType),this.setInterpolation(s||this.DefaultInterpolation)}static toJSON(e){let t=e.constructor,n;if(t.toJSON!==this.toJSON)n=t.toJSON(e);else{n={name:e.name,times:ui(e.times,Array),values:ui(e.values,Array)};let s=e.getInterpolation();s!==e.DefaultInterpolation&&(n.interpolation=s),la(e.settings)&&(n.settings={inTangents:ui(e.settings.inTangents,Array),outTangents:ui(e.settings.outTangents,Array)})}return n.type=e.ValueTypeName,n}InterpolantFactoryMethodDiscrete(e){return new Ra(this.times,this.values,this.getValueSize(),e)}InterpolantFactoryMethodLinear(e){return new Aa(this.times,this.values,this.getValueSize(),e)}InterpolantFactoryMethodSmooth(e){return new Ea(this.times,this.values,this.getValueSize(),e)}InterpolantFactoryMethodBezier(e){let t=new Ca(this.times,this.values,this.getValueSize(),e);return this.settings&&(t.inTangents=this.settings.inTangents,t.outTangents=this.settings.outTangents),t}setInterpolation(e){let t;switch(e){case Ci:t=this.InterpolantFactoryMethodDiscrete;break;case zi:t=this.InterpolantFactoryMethodLinear;break;case oa:t=this.InterpolantFactoryMethodSmooth;break;case gc:t=this.InterpolantFactoryMethodBezier;break}if(t===void 0){let n="unsupported interpolation for "+this.ValueTypeName+" keyframe track named "+this.name;if(this.createInterpolant===void 0)if(e!==this.DefaultInterpolation)this.setInterpolation(this.DefaultInterpolation);else throw new Error(n);return be("KeyframeTrack:",n),this}return this.createInterpolant=t,this}getInterpolation(){switch(this.createInterpolant){case this.InterpolantFactoryMethodDiscrete:return Ci;case this.InterpolantFactoryMethodLinear:return zi;case this.InterpolantFactoryMethodSmooth:return oa;case this.InterpolantFactoryMethodBezier:return gc}}getValueSize(){return this.values.length/this.times.length}shift(e){if(e!==0){let t=this.times;for(let n=0,s=t.length;n!==s;++n)t[n]+=e}return this}scale(e){if(e!==1){let t=this.times;for(let n=0,s=t.length;n!==s;++n)t[n]*=e;la(this.settings)&&(Uh(this.settings.inTangents,e),Uh(this.settings.outTangents,e))}return this}trim(e,t){let n=this.times,s=n.length,r=0,a=s-1;for(;r!==s&&n[r]<e;)++r;for(;a!==-1&&n[a]>t;)--a;if(++a,r!==0||a!==s){r>=a&&(a=Math.max(a,1),r=a-1);let o=this.getValueSize();this.times=n.slice(r,a),this.values=this.values.slice(r*o,a*o)}return this}validate(){let e=!0,t=this.getValueSize();t-Math.floor(t)!==0&&(ze("KeyframeTrack: Invalid value size in track.",this),e=!1);let n=this.times,s=this.values,r=n.length;r===0&&(ze("KeyframeTrack: Track is empty.",this),e=!1);let a=null;for(let o=0;o!==r;o++){let c=n[o];if(typeof c=="number"&&isNaN(c)){ze("KeyframeTrack: Time is not a valid number.",this,o,c),e=!1;break}if(a!==null&&a>c){ze("KeyframeTrack: Out of order keys.",this,o,c,a),e=!1;break}a=c}if(s!==void 0&&zf(s))for(let o=0,c=s.length;o!==c;++o){let l=s[o];if(isNaN(l)){ze("KeyframeTrack: Value is not a valid number.",this,o,l),e=!1;break}}return e}optimize(){let e=this.times.slice(),t=this.values.slice(),n=this.getValueSize(),s=this.getInterpolation()===oa,r=e.length-1,a=1;for(let o=1;o<r;++o){let c=!1,l=e[o],h=e[o+1];if(l!==h&&(o!==1||l!==e[0]))if(s)c=!0;else{let f=o*n,u=f-n,d=f+n;for(let g=0;g!==n;++g){let y=t[f+g];if(y!==t[u+g]||y!==t[d+g]){c=!0;break}}}if(c){if(o!==a){e[a]=e[o];let f=o*n,u=a*n;for(let d=0;d!==n;++d)t[u+d]=t[f+d]}++a}}if(r>0){e[a]=e[r];for(let o=r*n,c=a*n,l=0;l!==n;++l)t[c+l]=t[o+l];++a}return a!==e.length?(this.times=e.slice(0,a),this.values=t.slice(0,a*n)):(this.times=e,this.values=t),this}clone(){let e=this.times.slice(),t=this.values.slice(),n=this.constructor,s=new n(this.name,e,t);return s.createInterpolant=this.createInterpolant,la(this.settings)&&(s.settings={inTangents:this.settings.inTangents.slice(),outTangents:this.settings.outTangents.slice()}),s}};function Uh(i,e){for(let t=0,n=i.length;t!==n;t+=2)i[t]*=e}Yt.prototype.ValueTypeName="";Yt.prototype.TimeBufferType=Float32Array;Yt.prototype.ValueBufferType=Float32Array;Yt.prototype.DefaultInterpolation=zi;var Kn=class extends Yt{constructor(e,t,n){super(e,t,n)}};Kn.prototype.ValueTypeName="bool";Kn.prototype.ValueBufferType=Array;Kn.prototype.DefaultInterpolation=Ci;Kn.prototype.InterpolantFactoryMethodLinear=void 0;Kn.prototype.InterpolantFactoryMethodSmooth=void 0;var hr=class extends Yt{constructor(e,t,n,s){super(e,t,n,s)}};hr.prototype.ValueTypeName="color";var Jn=class extends Yt{constructor(e,t,n,s){super(e,t,n,s)}};Jn.prototype.ValueTypeName="number";var za=class extends Nn{constructor(e,t,n,s){super(e,t,n,s)}interpolate_(e,t,n,s){let r=this.resultBuffer,a=this.sampleValues,o=this.valueSize,c=(n-t)/(s-t),l=e*o;for(let h=l+o;l!==h;l+=4)Qt.slerpFlat(r,0,a,l-o,a,l,c);return r}},$n=class extends Yt{constructor(e,t,n,s){super(e,t,n,s)}InterpolantFactoryMethodLinear(e){return new za(this.times,this.values,this.getValueSize(),e)}};$n.prototype.ValueTypeName="quaternion";$n.prototype.InterpolantFactoryMethodSmooth=void 0;var jn=class extends Yt{constructor(e,t,n){super(e,t,n)}};jn.prototype.ValueTypeName="string";jn.prototype.ValueBufferType=Array;jn.prototype.DefaultInterpolation=Ci;jn.prototype.InterpolantFactoryMethodLinear=void 0;jn.prototype.InterpolantFactoryMethodSmooth=void 0;var mi=class extends Yt{constructor(e,t,n,s){super(e,t,n,s)}};mi.prototype.ValueTypeName="vector";var ur=class{constructor(e="",t=-1,n=[],s=du){this.name=e,this.tracks=n,this.duration=t,this.blendMode=s,this.uuid=xn(),this.userData={},this.duration<0&&this.resetDuration()}static parse(e){let t=[],n=e.tracks,s=1/(e.fps||1);for(let a=0,o=n.length;a!==o;++a)t.push(bd(n[a]).scale(s));let r=new this(e.name,e.duration,t,e.blendMode);return r.uuid=e.uuid,r.userData=JSON.parse(e.userData||"{}"),r}static toJSON(e){let t=[],n=e.tracks,s={name:e.name,duration:e.duration,tracks:t,uuid:e.uuid,blendMode:e.blendMode,userData:JSON.stringify(e.userData)};for(let r=0,a=n.length;r!==a;++r)t.push(Yt.toJSON(n[r]));return s}static CreateFromMorphTargetSequence(e,t,n,s){let r=t.length,a=[];for(let o=0;o<r;o++){let c=[],l=[];c.push((o+r-1)%r,o,(o+1)%r),l.push(0,1,0);let h=gd(c);c=Oh(c,1,h),l=Oh(l,1,h),!s&&c[0]===0&&(c.push(r),l.push(l[0])),a.push(new Jn(".morphTargetInfluences["+t[o].name+"]",c,l).scale(1/n))}return new this(e,-1,a)}static findByName(e,t){let n=e;if(!Array.isArray(e)){let s=e;n=s.geometry&&s.geometry.animations||s.animations}for(let s=0;s<n.length;s++)if(n[s].name===t)return n[s];return null}static CreateClipsFromMorphTargetSequences(e,t,n){let s={},r=/^([\w-]*?)([\d]+)$/;for(let o=0,c=e.length;o<c;o++){let l=e[o],h=l.name.match(r);if(h&&h.length>1){let f=h[1],u=s[f];u||(s[f]=u=[]),u.push(l)}}let a=[];for(let o in s)a.push(this.CreateFromMorphTargetSequence(o,s[o],t,n));return a}resetDuration(){let e=this.tracks,t=0;for(let n=0,s=e.length;n!==s;++n){let r=this.tracks[n];t=Math.max(t,r.times[r.times.length-1])}return this.duration=t,this}trim(){for(let e=0;e<this.tracks.length;e++)this.tracks[e].trim(0,this.duration);return this}validate(){let e=!0;for(let t=0;t<this.tracks.length;t++)e=e&&this.tracks[t].validate();return e}optimize(){for(let e=0;e<this.tracks.length;e++)this.tracks[e].optimize();return this}clone(){let e=[];for(let n=0;n<this.tracks.length;n++)e.push(this.tracks[n].clone());let t=new this.constructor(this.name,this.duration,e,this.blendMode);return t.userData=JSON.parse(JSON.stringify(this.userData)),t}toJSON(){return this.constructor.toJSON(this)}};function vd(i){switch(i.toLowerCase()){case"scalar":case"double":case"float":case"number":case"integer":return Jn;case"vector":case"vector2":case"vector3":case"vector4":return mi;case"color":return hr;case"quaternion":return $n;case"bool":case"boolean":return Kn;case"string":return jn}throw new Error("THREE.KeyframeTrack: Unsupported typeName: "+i)}function bd(i){if(i.type===void 0)throw new Error("THREE.KeyframeTrack: track type undefined, can not parse");let e=vd(i.type);if(i.times===void 0){let n=[],s=[];_d(i.keys,n,s,"value"),i.times=n,i.values=s}let t;return e.parse!==void 0?t=e.parse(i):t=new e(i.name,i.times,i.values,i.interpolation),la(i.settings)&&(t.settings={inTangents:ui(i.settings.inTangents,Float32Array),outTangents:ui(i.settings.outTangents,Float32Array)}),t}var zn={enabled:!1,files:{},add:function(i,e){this.enabled!==!1&&(Fh(i)||(this.files[i]=e))},get:function(i){if(this.enabled!==!1&&!Fh(i))return this.files[i]},remove:function(i){delete this.files[i]},clear:function(){this.files={}}};function Fh(i){try{let e=i.slice(i.indexOf(":")+1);return new URL(e).protocol==="blob:"}catch{return!1}}var Ia=class{constructor(e,t,n){let s=this,r=!1,a=0,o=0,c,l=[];this.onStart=void 0,this.onLoad=e,this.onProgress=t,this.onError=n,this._abortController=null,this.itemStart=function(h){o++,r===!1&&s.onStart!==void 0&&s.onStart(h,a,o),r=!0},this.itemEnd=function(h){a++,s.onProgress!==void 0&&s.onProgress(h,a,o),a===o&&(r=!1,s.onLoad!==void 0&&s.onLoad())},this.itemError=function(h){s.onError!==void 0&&s.onError(h)},this.resolveURL=function(h){return h=h.normalize("NFC"),c?c(h):h},this.setURLModifier=function(h){return c=h,this},this.addHandler=function(h,f){return l.push(h,f),this},this.removeHandler=function(h){let f=l.indexOf(h);return f!==-1&&l.splice(f,2),this},this.getHandler=function(h){for(let f=0,u=l.length;f<u;f+=2){let d=l[f],g=l[f+1];if(d.global&&(d.lastIndex=0),d.test(h))return g}return null},this.abort=function(){return this.abortController.abort(),this._abortController=null,this}}get abortController(){return this._abortController||(this._abortController=new AbortController),this._abortController}},zu=new Ia,Dn=class{constructor(e){this.manager=e!==void 0?e:zu,this.crossOrigin="anonymous",this.withCredentials=!1,this.path="",this.resourcePath="",this.requestHeader={},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}load(){}loadAsync(e,t){let n=this;return new Promise(function(s,r){n.load(e,s,t,r)})}parse(){}setCrossOrigin(e){return this.crossOrigin=e,this}setWithCredentials(e){return this.withCredentials=e,this}setPath(e){return this.path=e,this}setResourcePath(e){return this.resourcePath=e,this}setRequestHeader(e){return this.requestHeader=e,this}abort(){return this}};Dn.DEFAULT_MATERIAL_NAME="__DEFAULT";var qn={},bc=class extends Error{constructor(e,t){super(e),this.response=t}},Ss=class extends Dn{constructor(e){super(e),this.mimeType="",this.responseType="",this._abortController=new AbortController}load(e,t,n,s){e===void 0&&(e=""),this.path!==void 0&&(e=this.path+e),e=this.manager.resolveURL(e);let r=zn.get(`file:${e}`);if(r!==void 0){this.manager.itemStart(e),setTimeout(()=>{t&&t(r),this.manager.itemEnd(e)},0);return}if(qn[e]!==void 0){qn[e].push({onLoad:t,onProgress:n,onError:s});return}qn[e]=[],qn[e].push({onLoad:t,onProgress:n,onError:s});let a=new Request(e,{headers:new Headers(this.requestHeader),credentials:this.withCredentials?"include":"same-origin",signal:typeof AbortSignal.any=="function"?AbortSignal.any([this._abortController.signal,this.manager.abortController.signal]):this._abortController.signal}),o=this.mimeType,c=this.responseType;fetch(a).then(l=>{if(l.status===200||l.status===0){if(l.status===0&&be("FileLoader: HTTP Status 0 received."),typeof ReadableStream>"u"||l.body===void 0||l.body.getReader===void 0)return l;let h=qn[e],f=l.body.getReader(),u=l.headers.get("X-File-Size")||l.headers.get("Content-Length"),d=u?parseInt(u):0,g=d!==0,y=0,m=new ReadableStream({start(p){T();function T(){f.read().then(({done:R,value:v})=>{if(R)p.close();else{y+=v.byteLength;let b=new ProgressEvent("progress",{lengthComputable:g,loaded:y,total:d});for(let S=0,A=h.length;S<A;S++){let _=h[S];_.onProgress&&_.onProgress(b)}p.enqueue(v),T()}},R=>{p.error(R)})}}});return new Response(m)}else throw new bc(`fetch for "${l.url}" responded with ${l.status}: ${l.statusText}`,l)}).then(l=>{switch(c){case"arraybuffer":return l.arrayBuffer();case"blob":return l.blob();case"document":return l.text().then(h=>new DOMParser().parseFromString(h,o));case"json":return l.json();default:if(o==="")return l.text();{let f=/charset="?([^;"\s]*)"?/i.exec(o),u=f&&f[1]?f[1].toLowerCase():void 0,d=new TextDecoder(u);return l.arrayBuffer().then(g=>d.decode(g))}}}).then(l=>{zn.add(`file:${e}`,l);let h=qn[e];delete qn[e];for(let f=0,u=h.length;f<u;f++){let d=h[f];d.onLoad&&d.onLoad(l)}}).catch(l=>{let h=qn[e];if(h===void 0)throw this.manager.itemError(e),l;delete qn[e];for(let f=0,u=h.length;f<u;f++){let d=h[f];d.onError&&d.onError(l)}this.manager.itemError(e)}).finally(()=>{this.manager.itemEnd(e)}),this.manager.itemStart(e)}setResponseType(e){return this.responseType=e,this}setMimeType(e){return this.mimeType=e,this}abort(){return this._abortController.abort(),this._abortController=new AbortController,this}};var ss=new WeakMap,Pa=class extends Dn{constructor(e){super(e)}load(e,t,n,s){this.path!==void 0&&(e=this.path+e),e=this.manager.resolveURL(e);let r=this,a=zn.get(`image:${e}`);if(a!==void 0){if(a.complete===!0)r.manager.itemStart(e),setTimeout(function(){t&&t(a),r.manager.itemEnd(e)},0);else{let f=ss.get(a);f===void 0&&(f=[],ss.set(a,f)),f.push({onLoad:t,onError:s})}return a}let o=us("img");function c(){h(),t&&t(this);let f=ss.get(this)||[];for(let u=0;u<f.length;u++){let d=f[u];d.onLoad&&d.onLoad(this)}ss.delete(this),r.manager.itemEnd(e)}function l(f){h(),s&&s(f),zn.remove(`image:${e}`);let u=ss.get(this)||[];for(let d=0;d<u.length;d++){let g=u[d];g.onError&&g.onError(f)}ss.delete(this),r.manager.itemError(e),r.manager.itemEnd(e)}function h(){o.removeEventListener("load",c,!1),o.removeEventListener("error",l,!1)}return o.addEventListener("load",c,!1),o.addEventListener("error",l,!1),e.slice(0,5)!=="data:"&&this.crossOrigin!==void 0&&(o.crossOrigin=this.crossOrigin),zn.add(`image:${e}`,o),r.manager.itemStart(e),o.src=e,o}};var fr=class extends Dn{constructor(e){super(e)}load(e,t,n,s){let r=new Rt,a=new Pa(this.manager);return a.setCrossOrigin(this.crossOrigin),a.setPath(this.path),a.load(e,function(o){r.image=o,r.needsUpdate=!0,t!==void 0&&t(r)},n,s),r}},Di=class extends ut{constructor(e,t=1){super(),this.isLight=!0,this.type="Light",this.color=new Ce(e),this.intensity=t}copy(e,t){return super.copy(e,t),this.color.copy(e.color),this.intensity=e.intensity,this}toJSON(e){let t=super.toJSON(e);return t.object.color=this.color.getHex(),t.object.intensity=this.intensity,t}};var pc=new Ne,Bh=new O,kh=new O,ws=class{constructor(e){this.camera=e,this.intensity=1,this.bias=0,this.biasNode=null,this.normalBias=0,this.radius=1,this.blurSamples=8,this.mapSize=new Oe(512,512),this.mapType=Zt,this.map=null,this.mapPass=null,this.matrix=new Ne,this.autoUpdate=!0,this.needsUpdate=!1,this._frustum=new xs,this._frameExtents=new Oe(1,1),this._viewportCount=1,this._viewports=[new et(0,0,1,1)]}getViewportCount(){return this._viewportCount}getCamera(){return this.camera}getFrustum(){return this._frustum}updateMatrices(e){let t=this.camera;Bh.setFromMatrixPosition(e.matrixWorld),t.position.copy(Bh),kh.setFromMatrixPosition(e.target.matrixWorld),t.lookAt(kh),t.updateMatrixWorld(),this._updateMatrix(t,this.matrix,this._frustum)}_updateMatrix(e,t,n,s){pc.multiplyMatrices(e.projectionMatrix,e.matrixWorldInverse),n.setFromProjectionMatrix(pc,e.coordinateSystem,e.reversedDepth);let r=this._frameExtents,a=s?s.z/r.x:1,o=s?s.w/r.y:1,c=s?s.x/r.x:0,l=s?s.y/r.y:0;e.coordinateSystem===hs||e.reversedDepth?t.set(.5*a,0,0,.5*a+c,0,.5*o,0,.5*o+l,0,0,1,0,0,0,0,1):t.set(.5*a,0,0,.5*a+c,0,.5*o,0,.5*o+l,0,0,.5,.5,0,0,0,1),t.multiply(pc)}getViewport(e){return this._viewports[e]}getFrameExtents(){return this._frameExtents}dispose(){this.map&&this.map.dispose(),this.mapPass&&this.mapPass.dispose()}copy(e){return this.camera=e.camera.clone(),this.intensity=e.intensity,this.bias=e.bias,this.radius=e.radius,this.autoUpdate=e.autoUpdate,this.needsUpdate=e.needsUpdate,this.normalBias=e.normalBias,this.blurSamples=e.blurSamples,this.mapSize.copy(e.mapSize),this.biasNode=e.biasNode,this}clone(){return new this.constructor().copy(this)}toJSON(){let e={};return e.intensity=this.intensity,e.bias=this.bias,e.normalBias=this.normalBias,e.radius=this.radius,e.blurSamples=this.blurSamples,e.mapSize=this.mapSize.toArray(),e.camera=this.camera.toJSON(!1).object,delete e.camera.matrix,e}},ra=new O,aa=new Qt,Cn=new O,dr=class extends ut{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new Ne,this.projectionMatrix=new Ne,this.projectionMatrixInverse=new Ne,this.coordinateSystem=_n,this._reversedDepth=!1}get reversedDepth(){return this._reversedDepth}copy(e,t){return super.copy(e,t),this.matrixWorldInverse.copy(e.matrixWorldInverse),this.projectionMatrix.copy(e.projectionMatrix),this.projectionMatrixInverse.copy(e.projectionMatrixInverse),this.coordinateSystem=e.coordinateSystem,this}getWorldDirection(e){return super.getWorldDirection(e).negate()}updateMatrixWorld(e){super.updateMatrixWorld(e),this.matrixWorld.decompose(ra,aa,Cn),Cn.x===1&&Cn.y===1&&Cn.z===1?this.matrixWorldInverse.copy(this.matrixWorld).invert():this.matrixWorldInverse.compose(ra,aa,Cn.set(1,1,1)).invert()}updateWorldMatrix(e,t,n=!1){super.updateWorldMatrix(e,t,n),this.matrixWorld.decompose(ra,aa,Cn),Cn.x===1&&Cn.y===1&&Cn.z===1?this.matrixWorldInverse.copy(this.matrixWorld).invert():this.matrixWorldInverse.compose(ra,aa,Cn.set(1,1,1)).invert()}clone(){return new this.constructor().copy(this)}},hi=new O,Vh=new Oe,Gh=new Oe,xt=class extends dr{constructor(e=50,t=1,n=.1,s=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=e,this.zoom=1,this.near=n,this.far=s,this.focus=10,this.aspect=t,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(e,t){return super.copy(e,t),this.fov=e.fov,this.zoom=e.zoom,this.near=e.near,this.far=e.far,this.focus=e.focus,this.aspect=e.aspect,this.view=e.view===null?null:Object.assign({},e.view),this.filmGauge=e.filmGauge,this.filmOffset=e.filmOffset,this}setFocalLength(e){let t=.5*this.getFilmHeight()/e;this.fov=Ii*2*Math.atan(t),this.updateProjectionMatrix()}getFocalLength(){let e=Math.tan(qs*.5*this.fov);return .5*this.getFilmHeight()/e}getEffectiveFOV(){return Ii*2*Math.atan(Math.tan(qs*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}getViewBounds(e,t,n){hi.set(-1,-1,.5).applyMatrix4(this.projectionMatrixInverse),t.set(hi.x,hi.y).multiplyScalar(-e/hi.z),hi.set(1,1,.5).applyMatrix4(this.projectionMatrixInverse),n.set(hi.x,hi.y).multiplyScalar(-e/hi.z)}getViewSize(e,t){return this.getViewBounds(e,Vh,Gh),t.subVectors(Gh,Vh)}setViewOffset(e,t,n,s,r,a){this.aspect=e/t,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=e,this.view.fullHeight=t,this.view.offsetX=n,this.view.offsetY=s,this.view.width=r,this.view.height=a,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){let e=this.near,t=e*Math.tan(qs*.5*this.fov)/this.zoom,n=2*t,s=this.aspect*n,r=-.5*s,a=this.view;if(this.view!==null&&this.view.enabled){let c=a.fullWidth,l=a.fullHeight;r+=a.offsetX*s/c,t-=a.offsetY*n/l,s*=a.width/c,n*=a.height/l}let o=this.filmOffset;o!==0&&(r+=e*o/this.getFilmWidth()),this.projectionMatrix.makePerspective(r,r+s,t,t-n,e,this.far,this.coordinateSystem,this.reversedDepth),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(e){let t=super.toJSON(e);return t.object.fov=this.fov,t.object.zoom=this.zoom,t.object.near=this.near,t.object.far=this.far,t.object.focus=this.focus,t.object.aspect=this.aspect,this.view!==null&&(t.object.view=Object.assign({},this.view)),t.object.filmGauge=this.filmGauge,t.object.filmOffset=this.filmOffset,t}},Sc=class extends ws{constructor(){super(new xt(50,1,.5,500)),this.isSpotLightShadow=!0,this.focus=1,this.aspect=1}updateMatrices(e){let t=this.camera,n=Ii*2*e.angle*this.focus,s=this.mapSize.width/this.mapSize.height*this.aspect,r=e.distance||t.far;(n!==t.fov||s!==t.aspect||r!==t.far)&&(t.fov=n,t.aspect=s,t.far=r,t.updateProjectionMatrix()),super.updateMatrices(e)}copy(e){return super.copy(e),this.focus=e.focus,this.aspect=e.aspect,this}toJSON(){let e=super.toJSON();return e.focus=this.focus,e.aspect=this.aspect,e}},pr=class extends Di{constructor(e,t,n=0,s=Math.PI/3,r=0,a=2){super(e,t),this.isSpotLight=!0,this.type="SpotLight",this.position.copy(ut.DEFAULT_UP),this.updateMatrix(),this.target=new ut,this.distance=n,this.angle=s,this.penumbra=r,this.decay=a,this.map=null,this.shadow=new Sc}get power(){return this.intensity*Math.PI}set power(e){this.intensity=e/Math.PI}dispose(){super.dispose(),this.shadow.dispose()}copy(e,t){return super.copy(e,t),this.distance=e.distance,this.angle=e.angle,this.penumbra=e.penumbra,this.decay=e.decay,this.target=e.target.clone(),this.map=e.map,this.shadow=e.shadow.clone(),this}toJSON(e){let t=super.toJSON(e);return t.object.distance=this.distance,t.object.angle=this.angle,t.object.decay=this.decay,t.object.penumbra=this.penumbra,t.object.target=this.target.uuid,this.map&&this.map.isTexture&&(t.object.map=this.map.toJSON(e).uuid),t.object.shadow=this.shadow.toJSON(),t}},wc=class extends ws{constructor(){super(new xt(90,1,.5,500)),this.isPointLightShadow=!0}},mr=class extends Di{constructor(e,t,n=0,s=2){super(e,t),this.isPointLight=!0,this.type="PointLight",this.distance=n,this.decay=s,this.shadow=new wc}get power(){return this.intensity*4*Math.PI}set power(e){this.intensity=e/(4*Math.PI)}dispose(){super.dispose(),this.shadow.dispose()}copy(e,t){return super.copy(e,t),this.distance=e.distance,this.decay=e.decay,this.shadow=e.shadow.clone(),this}toJSON(e){let t=super.toJSON(e);return t.object.distance=this.distance,t.object.decay=this.decay,t.object.shadow=this.shadow.toJSON(),t}},Mi=class extends dr{constructor(e=-1,t=1,n=1,s=-1,r=.1,a=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=e,this.right=t,this.top=n,this.bottom=s,this.near=r,this.far=a,this.updateProjectionMatrix()}copy(e,t){return super.copy(e,t),this.left=e.left,this.right=e.right,this.top=e.top,this.bottom=e.bottom,this.near=e.near,this.far=e.far,this.zoom=e.zoom,this.view=e.view===null?null:Object.assign({},e.view),this}setViewOffset(e,t,n,s,r,a){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=e,this.view.fullHeight=t,this.view.offsetX=n,this.view.offsetY=s,this.view.width=r,this.view.height=a,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){let e=(this.right-this.left)/(2*this.zoom),t=(this.top-this.bottom)/(2*this.zoom),n=(this.right+this.left)/2,s=(this.top+this.bottom)/2,r=n-e,a=n+e,o=s+t,c=s-t;if(this.view!==null&&this.view.enabled){let l=(this.right-this.left)/this.view.fullWidth/this.zoom,h=(this.top-this.bottom)/this.view.fullHeight/this.zoom;r+=l*this.view.offsetX,a=r+l*this.view.width,o-=h*this.view.offsetY,c=o-h*this.view.height}this.projectionMatrix.makeOrthographic(r,a,o,c,this.near,this.far,this.coordinateSystem,this.reversedDepth),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(e){let t=super.toJSON(e);return t.object.zoom=this.zoom,t.object.left=this.left,t.object.right=this.right,t.object.top=this.top,t.object.bottom=this.bottom,t.object.near=this.near,t.object.far=this.far,this.view!==null&&(t.object.view=Object.assign({},this.view)),t}},Tc=class extends ws{constructor(){super(new Mi(-5,5,5,-5,.5,500)),this.isDirectionalLightShadow=!0}},Oi=class extends Di{constructor(e,t){super(e,t),this.isDirectionalLight=!0,this.type="DirectionalLight",this.position.copy(ut.DEFAULT_UP),this.updateMatrix(),this.target=new ut,this.shadow=new Tc}dispose(){super.dispose(),this.shadow.dispose()}copy(e){return super.copy(e),this.target=e.target.clone(),this.shadow=e.shadow.clone(),this}toJSON(e){let t=super.toJSON(e);return t.object.shadow=this.shadow.toJSON(),t.object.target=this.target.uuid,t}},Mr=class extends Di{constructor(e,t){super(e,t),this.isAmbientLight=!0,this.type="AmbientLight"}};var Qn=class{static extractUrlBase(e){let t=e.lastIndexOf("/");return t===-1?"./":e.slice(0,t+1)}static resolveURL(e,t){return typeof e!="string"||e===""?"":(/^https?:\/\//i.test(t)&&/^\//.test(e)&&(t=t.replace(/(^https?:\/\/[^\/]+).*/i,"$1")),/^(https?:)?\/\//i.test(e)||/^data:.*,.*$/i.test(e)||/^blob:.*$/i.test(e)?e:t+e)}};var mc=new WeakMap,gr=class extends Dn{constructor(e){super(e),this.isImageBitmapLoader=!0,typeof createImageBitmap>"u"&&be("ImageBitmapLoader: createImageBitmap() not supported."),typeof fetch>"u"&&be("ImageBitmapLoader: fetch() not supported."),this.options={premultiplyAlpha:"none"},this._abortController=new AbortController}setOptions(e){return this.options=e,this}load(e,t,n,s){e===void 0&&(e=""),this.path!==void 0&&(e=this.path+e),e=this.manager.resolveURL(e);let r=this,a=zn.get(`image-bitmap:${e}`);if(a!==void 0){if(r.manager.itemStart(e),a.then){a.then(l=>{mc.has(a)===!0?(s&&s(mc.get(a)),r.manager.itemError(e),r.manager.itemEnd(e)):(t&&t(l),r.manager.itemEnd(e))});return}setTimeout(function(){t&&t(a),r.manager.itemEnd(e)},0);return}let o={};o.credentials=this.crossOrigin==="anonymous"?"same-origin":"include",o.headers=this.requestHeader,o.signal=typeof AbortSignal.any=="function"?AbortSignal.any([this._abortController.signal,this.manager.abortController.signal]):this._abortController.signal;let c=fetch(e,o).then(function(l){return l.blob()}).then(function(l){return createImageBitmap(l,Object.assign({},r.options,{colorSpaceConversion:"none"}))}).then(function(l){return zn.add(`image-bitmap:${e}`,l),t&&t(l),r.manager.itemEnd(e),l}).catch(function(l){s&&s(l),mc.set(c,l),zn.remove(`image-bitmap:${e}`),r.manager.itemError(e),r.manager.itemEnd(e)});zn.add(`image-bitmap:${e}`,c),r.manager.itemStart(e)}abort(){return this._abortController.abort(),this._abortController=new AbortController,this}};var rs=-90,as=1,La=class extends ut{constructor(e,t,n){super(),this.type="CubeCamera",this.renderTarget=n,this.coordinateSystem=null,this.activeMipmapLevel=0;let s=new xt(rs,as,e,t);s.layers=this.layers,this.add(s);let r=new xt(rs,as,e,t);r.layers=this.layers,this.add(r);let a=new xt(rs,as,e,t);a.layers=this.layers,this.add(a);let o=new xt(rs,as,e,t);o.layers=this.layers,this.add(o);let c=new xt(rs,as,e,t);c.layers=this.layers,this.add(c);let l=new xt(rs,as,e,t);l.layers=this.layers,this.add(l)}updateCoordinateSystem(){let e=this.coordinateSystem,t=this.children.concat(),[n,s,r,a,o,c]=t;for(let l of t)this.remove(l);if(e===_n)n.up.set(0,1,0),n.lookAt(1,0,0),s.up.set(0,1,0),s.lookAt(-1,0,0),r.up.set(0,0,-1),r.lookAt(0,1,0),a.up.set(0,0,1),a.lookAt(0,-1,0),o.up.set(0,1,0),o.lookAt(0,0,1),c.up.set(0,1,0),c.lookAt(0,0,-1);else if(e===hs)n.up.set(0,-1,0),n.lookAt(-1,0,0),s.up.set(0,-1,0),s.lookAt(1,0,0),r.up.set(0,0,1),r.lookAt(0,1,0),a.up.set(0,0,-1),a.lookAt(0,-1,0),o.up.set(0,-1,0),o.lookAt(0,0,1),c.up.set(0,-1,0),c.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+e);for(let l of t)this.add(l),l.updateMatrixWorld()}update(e,t){this.parent===null&&this.updateMatrixWorld();let{renderTarget:n,activeMipmapLevel:s}=this;this.coordinateSystem!==e.coordinateSystem&&(this.coordinateSystem=e.coordinateSystem,this.updateCoordinateSystem());let[r,a,o,c,l,h]=this.children,f=e.getRenderTarget(),u=e.getActiveCubeFace(),d=e.getActiveMipmapLevel(),g=e.xr.enabled;e.xr.enabled=!1;let y=n.texture.generateMipmaps;n.texture.generateMipmaps=!1;let m=!1;e.isWebGLRenderer===!0?m=e.state.buffers.depth.getReversed():m=e.reversedDepthBuffer,e.setRenderTarget(n,0,s),m&&e.autoClear===!1&&e.clearDepth(),e.render(t,r),e.setRenderTarget(n,1,s),m&&e.autoClear===!1&&e.clearDepth(),e.render(t,a),e.setRenderTarget(n,2,s),m&&e.autoClear===!1&&e.clearDepth(),e.render(t,o),e.setRenderTarget(n,3,s),m&&e.autoClear===!1&&e.clearDepth(),e.render(t,c),e.setRenderTarget(n,4,s),m&&e.autoClear===!1&&e.clearDepth(),e.render(t,l),n.texture.generateMipmaps=y,e.setRenderTarget(n,5,s),m&&e.autoClear===!1&&e.clearDepth(),e.render(t,h),e.setRenderTarget(f,u,d),e.xr.enabled=g,n.texture.needsPMREMUpdate=!0}},Na=class extends xt{constructor(e=[]){super(),this.isArrayCamera=!0,this.isMultiViewCamera=!1,this.cameras=e}};var Qc="\\[\\]\\.:\\/",Sd=new RegExp("["+Qc+"]","g"),el="[^"+Qc+"]",wd="[^"+Qc.replace("\\.","")+"]",Td=/((?:WC+[\/:])*)/.source.replace("WC",el),Ed=/(WCOD+)?/.source.replace("WCOD",wd),Ad=/(?:\.(WC+)(?:\[(.+)\])?)?/.source.replace("WC",el),Rd=/\.(WC+)(?:\[(.+)\])?/.source.replace("WC",el),Cd=new RegExp("^"+Td+Ed+Ad+Rd+"$"),zd=["material","materials","bones","map"],Ec=class{constructor(e,t,n){let s=n||it.parseTrackName(t);this._targetGroup=e,this._bindings=e.subscribe_(t,s)}getValue(e,t){this.bind();let n=this._targetGroup.nCachedObjects_,s=this._bindings[n];s!==void 0&&s.getValue(e,t)}setValue(e,t){let n=this._bindings;for(let s=this._targetGroup.nCachedObjects_,r=n.length;s!==r;++s)n[s].setValue(e,t)}bind(){let e=this._bindings;for(let t=this._targetGroup.nCachedObjects_,n=e.length;t!==n;++t)e[t].bind()}unbind(){let e=this._bindings;for(let t=this._targetGroup.nCachedObjects_,n=e.length;t!==n;++t)e[t].unbind()}},it=class i{constructor(e,t,n){this.path=t,this.parsedPath=n||i.parseTrackName(t),this.node=i.findNode(e,this.parsedPath.nodeName),this.rootNode=e,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}static create(e,t,n){return e&&e.isAnimationObjectGroup?new i.Composite(e,t,n):new i(e,t,n)}static sanitizeNodeName(e){return e.replace(/\s/g,"_").replace(Sd,"")}static parseTrackName(e){let t=Cd.exec(e);if(t===null)throw new Error("THREE.PropertyBinding: Cannot parse trackName: "+e);let n={nodeName:t[2],objectName:t[3],objectIndex:t[4],propertyName:t[5],propertyIndex:t[6]},s=n.nodeName&&n.nodeName.lastIndexOf(".");if(s!==void 0&&s!==-1){let r=n.nodeName.substring(s+1);zd.indexOf(r)!==-1&&(n.nodeName=n.nodeName.substring(0,s),n.objectName=r)}if(n.propertyName===null||n.propertyName.length===0)throw new Error("THREE.PropertyBinding: can not parse propertyName from trackName: "+e);return n}static findNode(e,t){if(t===void 0||t===""||t==="."||t===-1||t===e.name||t===e.uuid)return e;if(e.skeleton){let n=e.skeleton.getBoneByName(t);if(n!==void 0)return n}if(e.children){let n=function(r){for(let a=0;a<r.length;a++){let o=r[a];if(o.name===t||o.uuid===t)return o;let c=n(o.children);if(c)return c}return null},s=n(e.children);if(s)return s}return null}_getValue_unavailable(){}_setValue_unavailable(){}_getValue_direct(e,t){e[t]=this.targetObject[this.propertyName]}_getValue_array(e,t){let n=this.resolvedProperty;for(let s=0,r=n.length;s!==r;++s)e[t++]=n[s]}_getValue_arrayElement(e,t){e[t]=this.resolvedProperty[this.propertyIndex]}_getValue_toArray(e,t){this.resolvedProperty.toArray(e,t)}_setValue_direct(e,t){this.targetObject[this.propertyName]=e[t]}_setValue_direct_setNeedsUpdate(e,t){this.targetObject[this.propertyName]=e[t],this.targetObject.needsUpdate=!0}_setValue_direct_setMatrixWorldNeedsUpdate(e,t){this.targetObject[this.propertyName]=e[t],this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_array(e,t){let n=this.resolvedProperty;for(let s=0,r=n.length;s!==r;++s)n[s]=e[t++]}_setValue_array_setNeedsUpdate(e,t){let n=this.resolvedProperty;for(let s=0,r=n.length;s!==r;++s)n[s]=e[t++];this.targetObject.needsUpdate=!0}_setValue_array_setMatrixWorldNeedsUpdate(e,t){let n=this.resolvedProperty;for(let s=0,r=n.length;s!==r;++s)n[s]=e[t++];this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_arrayElement(e,t){this.resolvedProperty[this.propertyIndex]=e[t]}_setValue_arrayElement_setNeedsUpdate(e,t){this.resolvedProperty[this.propertyIndex]=e[t],this.targetObject.needsUpdate=!0}_setValue_arrayElement_setMatrixWorldNeedsUpdate(e,t){this.resolvedProperty[this.propertyIndex]=e[t],this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_fromArray(e,t){this.resolvedProperty.fromArray(e,t)}_setValue_fromArray_setNeedsUpdate(e,t){this.resolvedProperty.fromArray(e,t),this.targetObject.needsUpdate=!0}_setValue_fromArray_setMatrixWorldNeedsUpdate(e,t){this.resolvedProperty.fromArray(e,t),this.targetObject.matrixWorldNeedsUpdate=!0}_getValue_unbound(e,t){this.bind(),this.getValue(e,t)}_setValue_unbound(e,t){this.bind(),this.setValue(e,t)}bind(){let e=this.node,t=this.parsedPath,n=t.objectName,s=t.propertyName,r=t.propertyIndex;if(e||(e=i.findNode(this.rootNode,t.nodeName),this.node=e),this.getValue=this._getValue_unavailable,this.setValue=this._setValue_unavailable,!e){be("PropertyBinding: No target node found for track: "+this.path+".");return}if(n){let l=t.objectIndex;switch(n){case"materials":if(!e.material){ze("PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!e.material.materials){ze("PropertyBinding: Can not bind to material.materials as node.material does not have a materials array.",this);return}e=e.material.materials;break;case"bones":if(!e.skeleton){ze("PropertyBinding: Can not bind to bones as node does not have a skeleton.",this);return}e=e.skeleton.bones;for(let h=0;h<e.length;h++)if(e[h].name===l){l=h;break}break;case"map":if("map"in e){e=e.map;break}if(!e.material){ze("PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!e.material.map){ze("PropertyBinding: Can not bind to material.map as node.material does not have a map.",this);return}e=e.material.map;break;default:if(e[n]===void 0){ze("PropertyBinding: Can not bind to objectName of node undefined.",this);return}e=e[n]}if(l!==void 0){if(e[l]===void 0){ze("PropertyBinding: Trying to bind to objectIndex of objectName, but is undefined.",this,e);return}e=e[l]}}let a=e[s];if(a===void 0){let l=t.nodeName;ze("PropertyBinding: Trying to update property for track: "+l+"."+s+" but it wasn't found.",e);return}let o=this.Versioning.None;this.targetObject=e,e.isMaterial===!0?o=this.Versioning.NeedsUpdate:e.isObject3D===!0&&(o=this.Versioning.MatrixWorldNeedsUpdate);let c=this.BindingType.Direct;if(r!==void 0){if(s==="morphTargetInfluences"){if(!e.geometry){ze("PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.",this);return}if(!e.geometry.morphAttributes){ze("PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.morphAttributes.",this);return}e.morphTargetDictionary[r]!==void 0&&(r=e.morphTargetDictionary[r])}c=this.BindingType.ArrayElement,this.resolvedProperty=a,this.propertyIndex=r}else a.fromArray!==void 0&&a.toArray!==void 0?(c=this.BindingType.HasFromToArray,this.resolvedProperty=a):Array.isArray(a)?(c=this.BindingType.EntireArray,this.resolvedProperty=a):this.propertyName=s;this.getValue=this.GetterByBindingType[c],this.setValue=this.SetterByBindingTypeAndVersioning[c][o]}unbind(){this.node=null,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}};it.Composite=Ec;it.prototype.BindingType={Direct:0,EntireArray:1,ArrayElement:2,HasFromToArray:3};it.prototype.Versioning={None:0,NeedsUpdate:1,MatrixWorldNeedsUpdate:2};it.prototype.GetterByBindingType=[it.prototype._getValue_direct,it.prototype._getValue_array,it.prototype._getValue_arrayElement,it.prototype._getValue_toArray];it.prototype.SetterByBindingTypeAndVersioning=[[it.prototype._setValue_direct,it.prototype._setValue_direct_setNeedsUpdate,it.prototype._setValue_direct_setMatrixWorldNeedsUpdate],[it.prototype._setValue_array,it.prototype._setValue_array_setNeedsUpdate,it.prototype._setValue_array_setMatrixWorldNeedsUpdate],[it.prototype._setValue_arrayElement,it.prototype._setValue_arrayElement_setNeedsUpdate,it.prototype._setValue_arrayElement_setMatrixWorldNeedsUpdate],[it.prototype._setValue_fromArray,it.prototype._setValue_fromArray_setNeedsUpdate,it.prototype._setValue_fromArray_setMatrixWorldNeedsUpdate]];var Hg=new Float32Array(1);var Ac=class i{static{i.prototype.isMatrix2=!0}constructor(e,t,n,s){this.elements=[1,0,0,1],e!==void 0&&this.set(e,t,n,s)}identity(){return this.set(1,0,0,1),this}fromArray(e,t=0){for(let n=0;n<4;n++)this.elements[n]=e[n+t];return this}set(e,t,n,s){let r=this.elements;return r[0]=e,r[2]=t,r[1]=n,r[3]=s,this}};function tl(i,e,t,n){let s=Id(n);switch(t){case qc:return i*e;case Ga:return i*e/s.components*s.byteLength;case Ha:return i*e/s.components*s.byteLength;case xi:return i*e*2/s.components*s.byteLength;case Wa:return i*e*2/s.components*s.byteLength;case Yc:return i*e*3/s.components*s.byteLength;case sn:return i*e*4/s.components*s.byteLength;case Xa:return i*e*4/s.components*s.byteLength;case yr:case vr:return Math.floor((i+3)/4)*Math.floor((e+3)/4)*8;case br:case Sr:return Math.floor((i+3)/4)*Math.floor((e+3)/4)*16;case Ya:case Ka:return Math.max(i,16)*Math.max(e,8)/4;case qa:case Za:return Math.max(i,8)*Math.max(e,8)/2;case Ja:case $a:case Qa:case eo:return Math.floor((i+3)/4)*Math.floor((e+3)/4)*8;case ja:case wr:case to:return Math.floor((i+3)/4)*Math.floor((e+3)/4)*16;case no:return Math.floor((i+3)/4)*Math.floor((e+3)/4)*16;case io:return Math.floor((i+4)/5)*Math.floor((e+3)/4)*16;case so:return Math.floor((i+4)/5)*Math.floor((e+4)/5)*16;case ro:return Math.floor((i+5)/6)*Math.floor((e+4)/5)*16;case ao:return Math.floor((i+5)/6)*Math.floor((e+5)/6)*16;case oo:return Math.floor((i+7)/8)*Math.floor((e+4)/5)*16;case co:return Math.floor((i+7)/8)*Math.floor((e+5)/6)*16;case lo:return Math.floor((i+7)/8)*Math.floor((e+7)/8)*16;case ho:return Math.floor((i+9)/10)*Math.floor((e+4)/5)*16;case uo:return Math.floor((i+9)/10)*Math.floor((e+5)/6)*16;case fo:return Math.floor((i+9)/10)*Math.floor((e+7)/8)*16;case po:return Math.floor((i+9)/10)*Math.floor((e+9)/10)*16;case mo:return Math.floor((i+11)/12)*Math.floor((e+9)/10)*16;case Mo:return Math.floor((i+11)/12)*Math.floor((e+11)/12)*16;case go:case _o:case xo:return Math.ceil(i/4)*Math.ceil(e/4)*16;case yo:case vo:return Math.ceil(i/4)*Math.ceil(e/4)*8;case Tr:case bo:return Math.ceil(i/4)*Math.ceil(e/4)*16}throw new Error(`Unable to determine texture byte length for ${t} format.`)}function Id(i){switch(i){case Zt:case Gc:return{byteLength:1,components:1};case Rs:case Hc:case wn:return{byteLength:2,components:1};case ka:case Va:return{byteLength:2,components:4};case Sn:case Ba:case nn:return{byteLength:4,components:1};case Wc:case Xc:return{byteLength:4,components:3}}throw new Error(`THREE.TextureUtils: Unknown texture type ${i}.`)}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:"186"}}));typeof window<"u"&&(window.__THREE__?be("WARNING: Multiple instances of Three.js being imported."):window.__THREE__="186");function ju(){let i=null,e=!1,t=null,n=null;function s(r,a){n=i.requestAnimationFrame(s),t(r,a)}return{start:function(){e!==!0&&t!==null&&i!==null&&(n=i.requestAnimationFrame(s),e=!0)},stop:function(){i!==null&&i.cancelAnimationFrame(n),e=!1},setAnimationLoop:function(r){t=r},setContext:function(r){i=r}}}function Ld(i){let e=new WeakMap;function t(o,c){let l=o.array,h=o.usage,f=l.byteLength,u=i.createBuffer();i.bindBuffer(c,u),i.bufferData(c,l,h),o.onUploadCallback();let d;if(l instanceof Float32Array)d=i.FLOAT;else if(typeof Float16Array<"u"&&l instanceof Float16Array)d=i.HALF_FLOAT;else if(l instanceof Uint16Array)o.isFloat16BufferAttribute?d=i.HALF_FLOAT:d=i.UNSIGNED_SHORT;else if(l instanceof Int16Array)d=i.SHORT;else if(l instanceof Uint32Array)d=i.UNSIGNED_INT;else if(l instanceof Int32Array)d=i.INT;else if(l instanceof Int8Array)d=i.BYTE;else if(l instanceof Uint8Array)d=i.UNSIGNED_BYTE;else if(l instanceof Uint8ClampedArray)d=i.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+l);return{buffer:u,type:d,bytesPerElement:l.BYTES_PER_ELEMENT,version:o.version,size:f}}function n(o,c,l){let h=c.array,f=c.updateRanges;if(i.bindBuffer(l,o),f.length===0)i.bufferSubData(l,0,h);else{f.sort((d,g)=>d.start-g.start);let u=0;for(let d=1;d<f.length;d++){let g=f[u],y=f[d];y.start<=g.start+g.count+1?g.count=Math.max(g.count,y.start+y.count-g.start):(++u,f[u]=y)}f.length=u+1;for(let d=0,g=f.length;d<g;d++){let y=f[d];i.bufferSubData(l,y.start*h.BYTES_PER_ELEMENT,h,y.start,y.count)}c.clearUpdateRanges()}c.onUploadCallback()}function s(o){return o.isInterleavedBufferAttribute&&(o=o.data),e.get(o)}function r(o){o.isInterleavedBufferAttribute&&(o=o.data);let c=e.get(o);c&&(i.deleteBuffer(c.buffer),e.delete(o))}function a(o,c){if(o.isInterleavedBufferAttribute&&(o=o.data),o.isGLBufferAttribute){let h=e.get(o);(!h||h.version<o.version)&&e.set(o,{buffer:o.buffer,type:o.type,bytesPerElement:o.elementSize,version:o.version});return}let l=e.get(o);if(l===void 0)e.set(o,t(o,c));else if(l.version<o.version){if(l.size!==o.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");n(l.buffer,o,c),l.version=o.version}}return{get:s,remove:r,update:a}}var Nd=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,Dd=`#ifdef USE_ALPHAHASH
	const float ALPHA_HASH_SCALE = 0.05;
	float hash2D( vec2 value ) {
		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
	}
	float hash3D( vec3 value ) {
		return hash2D( vec2( hash2D( value.xy ), value.z ) );
	}
	float getAlphaHashThreshold( vec3 position ) {
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);
		float lerpFactor = fract( log2( pixScale ) );
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;
		return clamp( threshold , 1.0e-6, 1.0 );
	}
#endif`,Od=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,Ud=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,Fd=`#ifdef USE_ALPHATEST
	#ifdef ALPHA_TO_COVERAGE
	diffuseColor.a = smoothstep( alphaTest, alphaTest + fwidth( diffuseColor.a ), diffuseColor.a );
	if ( diffuseColor.a == 0.0 ) discard;
	#else
	if ( diffuseColor.a < alphaTest ) discard;
	#endif
#endif`,Bd=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,kd=`#ifdef USE_AOMAP
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
	reflectedLight.indirectDiffuse *= ambientOcclusion;
	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD )
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
	#endif
#endif`,Vd=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,Gd=`#ifdef USE_BATCHING
	#if ! defined( GL_ANGLE_multi_draw )
	#define gl_DrawID _gl_DrawID
	uniform int _gl_DrawID;
	#endif
	uniform highp sampler2D batchingTexture;
	uniform highp usampler2D batchingIdTexture;
	mat4 getBatchingMatrix( const in float i ) {
		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
	float getIndirectIndex( const in int i ) {
		int size = textureSize( batchingIdTexture, 0 ).x;
		int x = i % size;
		int y = i / size;
		return float( texelFetch( batchingIdTexture, ivec2( x, y ), 0 ).r );
	}
#endif
#ifdef USE_BATCHING_COLOR
	uniform sampler2D batchingColorTexture;
	vec4 getBatchingColor( const in float i ) {
		int size = textureSize( batchingColorTexture, 0 ).x;
		int j = int( i );
		int x = j % size;
		int y = j / size;
		return texelFetch( batchingColorTexture, ivec2( x, y ), 0 );
	}
#endif`,Hd=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( getIndirectIndex( gl_DrawID ) );
#endif`,Wd=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,Xd=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,qd=`float G_BlinnPhong_Implicit( ) {
	return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( specularColor, 1.0, dotVH );
	float G = G_BlinnPhong_Implicit( );
	float D = D_BlinnPhong( shininess, dotNH );
	return F * ( G * D );
} // validated`,Yd=`#ifdef USE_IRIDESCENCE
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {
		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );
	}
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - vec3( incidentIor ) ) / ( transmittedIor + vec3( incidentIor ) ) );
	}
	float IorToFresnel0( float transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));
	}
	vec3 evalSensitivity( float OPD, vec3 shift ) {
		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );
		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;
		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;
	}
	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {
		vec3 I;
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {
			return vec3( 1.0 );
		}
		float cosTheta2 = sqrt( cosTheta2Sq );
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) );		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3( 0.0 );
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21 ) + phi23;
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );
		vec3 C0 = R12 + Rs;
		I = C0;
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {
			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;
		}
		return max( I, vec3( 0.0 ) );
	}
#endif`,Zd=`#ifdef USE_BUMPMAP
	uniform sampler2D bumpMap;
	uniform float bumpScale;
	vec2 dHdxy_fwd() {
		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );
		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
		return vec2( dBx, dBy );
	}
	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm;
		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );
		float fDet = dot( vSigmaX, R1 ) * faceDirection;
		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );
	}
#endif`,Kd=`#if NUM_CLIPPING_PLANES > 0
	vec4 plane;
	#ifdef ALPHA_TO_COVERAGE
		float distanceToPlane, distanceGradient;
		float clipOpacity = 1.0;
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
			distanceGradient = fwidth( distanceToPlane ) / 2.0;
			clipOpacity *= smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			if ( clipOpacity == 0.0 ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			float unionClipOpacity = 1.0;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
				distanceGradient = fwidth( distanceToPlane ) / 2.0;
				unionClipOpacity *= 1.0 - smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			}
			#pragma unroll_loop_end
			clipOpacity *= 1.0 - unionClipOpacity;
		#endif
		diffuseColor.a *= clipOpacity;
		if ( diffuseColor.a == 0.0 ) discard;
	#else
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			bool clipped = true;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;
			}
			#pragma unroll_loop_end
			if ( clipped ) discard;
		#endif
	#endif
#endif`,Jd=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,$d=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,jd=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,Qd=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#endif`,ep=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#endif`,tp=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	varying vec4 vColor;
#endif`,np=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	vColor = vec4( 1.0 );
#endif
#ifdef USE_COLOR_ALPHA
	vColor *= color;
#elif defined( USE_COLOR )
	vColor.rgb *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.rgb *= instanceColor.rgb;
#endif
#ifdef USE_BATCHING_COLOR
	vColor *= getBatchingColor( getIndirectIndex( gl_DrawID ) );
#endif`,ip=`#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif
struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};
struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
	varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
#define inverseTransformDirection transformDirectionByInverseViewMatrix
vec3 transformNormalByInverseViewMatrix( in vec3 normal, in mat4 viewMatrix ) {
	return normalize( ( vec4( normal, 0.0 ) * viewMatrix ).xyz );
}
vec3 transformDirectionByInverseViewMatrix( in vec3 dir, in mat4 viewMatrix ) {
	return normalize( ( vec4( dir, 0.0 ) * viewMatrix ).xyz );
}
bool isPerspectiveMatrix( mat4 m ) {
	return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
	float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
	return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
	return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated`,sp=`#ifdef ENVMAP_TYPE_CUBE_UV
	#define cubeUV_minMipLevel 4.0
	#define cubeUV_minTileSize 16.0
	float getFace( vec3 direction ) {
		vec3 absDirection = abs( direction );
		float face = - 1.0;
		if ( absDirection.x > absDirection.z ) {
			if ( absDirection.x > absDirection.y )
				face = direction.x > 0.0 ? 0.0 : 3.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		} else {
			if ( absDirection.z > absDirection.y )
				face = direction.z > 0.0 ? 2.0 : 5.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		}
		return face;
	}
	vec2 getUV( vec3 direction, float face ) {
		vec2 uv;
		if ( face == 0.0 ) {
			uv = vec2( direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 1.0 ) {
			uv = vec2( - direction.x, - direction.z ) / abs( direction.y );
		} else if ( face == 2.0 ) {
			uv = vec2( - direction.x, direction.y ) / abs( direction.z );
		} else if ( face == 3.0 ) {
			uv = vec2( - direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 4.0 ) {
			uv = vec2( - direction.x, direction.z ) / abs( direction.y );
		} else {
			uv = vec2( direction.x, direction.y ) / abs( direction.z );
		}
		return 0.5 * ( uv + 1.0 );
	}
	vec3 bilinearCubeUV( sampler2D envMap, vec3 direction, float mipInt ) {
		float face = getFace( direction );
		float filterInt = max( cubeUV_minMipLevel - mipInt, 0.0 );
		mipInt = max( mipInt, cubeUV_minMipLevel );
		float faceSize = exp2( mipInt );
		highp vec2 uv = getUV( direction, face ) * ( faceSize - 2.0 ) + 1.0;
		if ( face > 2.0 ) {
			uv.y += faceSize;
			face -= 3.0;
		}
		uv.x += face * faceSize;
		uv.x += filterInt * 3.0 * cubeUV_minTileSize;
		uv.y += 4.0 * ( exp2( CUBEUV_MAX_MIP ) - faceSize );
		uv.x *= CUBEUV_TEXEL_WIDTH;
		uv.y *= CUBEUV_TEXEL_HEIGHT;
		#ifdef texture2DGradEXT
			return texture2DGradEXT( envMap, uv, vec2( 0.0 ), vec2( 0.0 ) ).rgb;
		#else
			return texture2D( envMap, uv ).rgb;
		#endif
	}
	#define cubeUV_r0 1.0
	#define cubeUV_m0 - 2.0
	#define cubeUV_r1 0.8
	#define cubeUV_m1 - 1.0
	#define cubeUV_r4 0.4
	#define cubeUV_m4 2.0
	#define cubeUV_r5 0.305
	#define cubeUV_m5 3.0
	#define cubeUV_r6 0.21
	#define cubeUV_m6 4.0
	float roughnessToMip( float roughness ) {
		float mip = 0.0;
		if ( roughness >= cubeUV_r1 ) {
			mip = ( cubeUV_r0 - roughness ) * ( cubeUV_m1 - cubeUV_m0 ) / ( cubeUV_r0 - cubeUV_r1 ) + cubeUV_m0;
		} else if ( roughness >= cubeUV_r4 ) {
			mip = ( cubeUV_r1 - roughness ) * ( cubeUV_m4 - cubeUV_m1 ) / ( cubeUV_r1 - cubeUV_r4 ) + cubeUV_m1;
		} else if ( roughness >= cubeUV_r5 ) {
			mip = ( cubeUV_r4 - roughness ) * ( cubeUV_m5 - cubeUV_m4 ) / ( cubeUV_r4 - cubeUV_r5 ) + cubeUV_m4;
		} else if ( roughness >= cubeUV_r6 ) {
			mip = ( cubeUV_r5 - roughness ) * ( cubeUV_m6 - cubeUV_m5 ) / ( cubeUV_r5 - cubeUV_r6 ) + cubeUV_m5;
		} else {
			mip = - 2.0 * log2( 1.16 * roughness );		}
		return mip;
	}
	vec4 textureCubeUV( sampler2D envMap, vec3 sampleDir, float roughness ) {
		float mip = clamp( roughnessToMip( roughness ), cubeUV_m0, CUBEUV_MAX_MIP );
		float mipF = fract( mip );
		float mipInt = floor( mip );
		vec3 color0 = bilinearCubeUV( envMap, sampleDir, mipInt );
		if ( mipF == 0.0 ) {
			return vec4( color0, 1.0 );
		} else {
			vec3 color1 = bilinearCubeUV( envMap, sampleDir, mipInt + 1.0 );
			return vec4( mix( color0, color1, mipF ), 1.0 );
		}
	}
#endif`,rp=`vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
	vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = bm * transformedTangent;
	#endif
#endif
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = im * transformedTangent;
	#endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
	transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
#endif`,ap=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,op=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,cp=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	#ifdef DECODE_VIDEO_TEXTURE_EMISSIVE
		emissiveColor = sRGBTransferEOTF( emissiveColor );
	#endif
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,lp=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,hp="gl_FragColor = linearToOutputTexel( gl_FragColor );",up=`vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}
vec4 sRGBTransferEOTF( in vec4 value ) {
	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 sRGBTransferOETF( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}`,fp=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vec3 cameraToFrag;
		if ( isOrthographic ) {
			cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToFrag = normalize( vWorldPosition - cameraPosition );
		}
		vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vec3 reflectVec = reflect( cameraToFrag, worldNormal );
		#else
			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
		#endif
	#else
		vec3 reflectVec = vReflect;
	#endif
	#ifdef ENVMAP_TYPE_CUBE
		vec4 envColor = textureCube( envMap, envMapRotation * reflectVec );
		#ifdef ENVMAP_BLENDING_MULTIPLY
			outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
		#elif defined( ENVMAP_BLENDING_MIX )
			outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
		#elif defined( ENVMAP_BLENDING_ADD )
			outgoingLight += envColor.xyz * specularStrength * reflectivity;
		#endif
	#endif
#endif`,dp=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform mat3 envMapRotation;
	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
#endif`,pp=`#ifdef USE_ENVMAP
	uniform float reflectivity;
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		varying vec3 vWorldPosition;
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif
#endif`,mp=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,Mp=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vWorldPosition = worldPosition.xyz;
	#else
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 worldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vReflect = reflect( cameraToVertex, worldNormal );
		#else
			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );
		#endif
	#endif
#endif`,gp=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,_p=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,xp=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,yp=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,vp=`#ifdef USE_GRADIENTMAP
	uniform sampler2D gradientMap;
#endif
vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );
	#ifdef USE_GRADIENTMAP
		return vec3( texture2D( gradientMap, coord ).r );
	#else
		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );
	#endif
}`,bp=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,Sp=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,wp=`varying vec3 vViewPosition;
struct LambertMaterial {
	vec3 diffuseColor;
	float specularStrength;
};
void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,Tp=`uniform bool receiveShadow;
uniform vec3 ambientLightColor;
#if defined( USE_LIGHT_PROBES )
	uniform vec3 lightProbe[ 9 ];
#endif
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {
	float x = normal.x, y = normal.y, z = normal.z;
	vec3 result = shCoefficients[ 0 ] * 0.886227;
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
	return result;
}
vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {
	vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );
	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
	return irradiance;
}
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
	vec3 irradiance = ambientLightColor;
	return irradiance;
}
float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
	float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
	if ( cutoffDistance > 0.0 ) {
		distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
	}
	return distanceFalloff;
}
float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {
	return smoothstep( coneCosine, penumbraCosine, angleCosine );
}
#if NUM_SUN_LIGHTS > 0
	struct SunLight {
		vec3 direction;
		vec3 color;
	};
	uniform SunLight sunLights[ NUM_SUN_LIGHTS ];
	void getSunLightInfo( const in SunLight sunLight, out IncidentLight light ) {
		light.color = sunLight.color;
		light.direction = sunLight.direction;
		light.visible = true;
	}
#endif
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
	void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {
		light.color = directionalLight.color;
		light.direction = directionalLight.direction;
		light.visible = true;
	}
#endif
#if NUM_POINT_LIGHTS > 0
	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;
	};
	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
	void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = pointLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float lightDistance = length( lVector );
		light.color = pointLight.color;
		light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
		light.visible = ( light.color != vec3( 0.0 ) );
	}
#endif
#if NUM_SPOT_LIGHTS > 0
	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;
	};
	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
	void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = spotLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float angleCos = dot( light.direction, spotLight.direction );
		float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );
		if ( spotAttenuation > 0.0 ) {
			float lightDistance = length( lVector );
			light.color = spotLight.color * spotAttenuation;
			light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
			light.visible = ( light.color != vec3( 0.0 ) );
		} else {
			light.color = vec3( 0.0 );
			light.visible = false;
		}
	}
#endif
#if NUM_RECT_AREA_LIGHTS > 0
	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};
	uniform sampler2D ltc_1;	uniform sampler2D ltc_2;
	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
#endif
#if NUM_HEMI_LIGHTS > 0
	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};
	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {
		float dotNL = dot( normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
		return irradiance;
	}
#endif
#include <lightprobes_pars_fragment>`,Ep=`#ifdef USE_ENVMAP
	vec3 getIBLIrradiance( const in vec3 normal ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * worldNormal, 1.0 );
			return PI * envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 reflectVec = reflect( - viewDir, normal );
			reflectVec = normalize( mix( reflectVec, normal, pow4( roughness ) ) );
			reflectVec = transformDirectionByInverseViewMatrix( reflectVec, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * reflectVec, roughness );
			return envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	#ifdef USE_RETROREFLECTION
		vec3 getIBLRetroRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
			#ifdef ENVMAP_TYPE_CUBE_UV
				vec3 retroVec = normalize( mix( viewDir, normal, pow4( roughness ) ) );
				retroVec = transformDirectionByInverseViewMatrix( retroVec, viewMatrix );
				vec4 envMapColor = textureCubeUV( envMap, envMapRotation * retroVec, roughness );
				return envMapColor.rgb * envMapIntensity;
			#else
				return vec3( 0.0 );
			#endif
		}
	#endif
	#ifdef USE_ANISOTROPY
		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
			#ifdef ENVMAP_TYPE_CUBE_UV
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
				return getIBLRadiance( viewDir, bentNormal, roughness );
			#else
				return vec3( 0.0 );
			#endif
		}
		#ifdef USE_RETROREFLECTION
			vec3 getIBLAnisotropyRetroRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
				#ifdef ENVMAP_TYPE_CUBE_UV
					vec3 bentNormal = cross( bitangent, viewDir );
					bentNormal = normalize( cross( bentNormal, bitangent ) );
					bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
					return getIBLRetroRadiance( viewDir, bentNormal, roughness );
				#else
					return vec3( 0.0 );
				#endif
			}
		#endif
	#endif
#endif`,Ap=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,Rp=`varying vec3 vViewPosition;
struct ToonMaterial {
	vec3 diffuseColor;
};
void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,Cp=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,zp=`varying vec3 vViewPosition;
struct BlinnPhongMaterial {
	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;
};
void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;
}
void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,Ip=`PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.diffuseContribution = diffuseColor.rgb * ( 1.0 - metalnessFactor );
material.metalness = metalnessFactor;
vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
material.roughness = max( roughnessFactor, 0.0525 );material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );
#ifdef IOR
	material.ior = ior;
	#ifdef USE_SPECULAR
		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;
		#ifdef USE_SPECULAR_COLORMAP
			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;
		#endif
		#ifdef USE_SPECULAR_INTENSITYMAP
			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;
		#endif
		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );
	#else
		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3( 1.0 );
		material.specularF90 = 1.0;
	#endif
	material.specularColor = min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3( 1.0 ) ) * specularIntensityFactor;
	material.specularColorBlended = mix( material.specularColor, diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = vec3( 0.04 );
	material.specularColorBlended = mix( material.specularColor, diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;
#endif
#ifdef USE_CLEARCOAT
	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3( 0.04 );
	material.clearcoatF90 = 1.0;
	#ifdef USE_CLEARCOATMAP
		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;
	#endif
	#ifdef USE_CLEARCOAT_ROUGHNESSMAP
		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;
	#endif
	material.clearcoat = saturate( material.clearcoat );	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.0525 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );
#endif
#ifdef USE_DISPERSION
	material.dispersion = dispersion;
#endif
#ifdef USE_RETROREFLECTION
	material.retroreflectivity = retroreflectivity;
#endif
#ifdef USE_IRIDESCENCE
	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;
	#ifdef USE_IRIDESCENCEMAP
		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;
	#endif
	#ifdef USE_IRIDESCENCE_THICKNESSMAP
		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;
	#else
		material.iridescenceThickness = iridescenceThicknessMaximum;
	#endif
#endif
#ifdef USE_SHEEN
	material.sheenColor = sheenColor;
	#ifdef USE_SHEEN_COLORMAP
		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;
	#endif
	material.sheenRoughness = clamp( sheenRoughness, 0.0001, 1.0 );
	#ifdef USE_SHEEN_ROUGHNESSMAP
		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;
	#endif
#endif
#ifdef USE_ANISOTROPY
	#ifdef USE_ANISOTROPYMAP
		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;
	#else
		vec2 anisotropyV = anisotropyVector;
	#endif
	material.anisotropy = length( anisotropyV );
	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );
	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;
#endif`,Pp=`uniform sampler2D dfgLUT;
struct PhysicalMaterial {
	vec3 diffuseColor;
	vec3 diffuseContribution;
	vec3 specularColor;
	vec3 specularColorBlended;
	float roughness;
	float metalness;
	float specularF90;
	float dispersion;
	vec2 dfg;
	vec3 multiScatteringCompensation;
	#ifdef USE_RETROREFLECTION
		float retroreflectivity;
	#endif
	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif
	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0Dielectric;
		vec3 iridescenceF0Metallic;
	#endif
	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif
	#ifdef IOR
		float ior;
	#endif
	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif
	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif
};
vec3 clearcoatSpecularDirect = vec3( 0.0 );
vec3 clearcoatSpecularIndirect = vec3( 0.0 );
vec3 sheenSpecularDirect = vec3( 0.0 );
vec3 sheenSpecularIndirect = vec3(0.0 );
vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );
    return ( f - vec3( f90 ) * x5 ) / ( 1.0 - x5 );
}
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
	float a2 = pow2( alpha );
	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
	return RECIPROCAL_PI * a2 / pow2( denom );
}
#ifdef USE_ANISOTROPY
	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {
		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		return 0.5 / max( gv + gl, EPSILON );
	}
	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {
		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;
		return RECIPROCAL_PI * a2 * pow2 ( w2 );
	}
#endif
#ifdef USE_CLEARCOAT
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {
		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = material.clearcoatRoughness;
		float alpha = pow2( roughness );
		vec3 halfDir = normalize( lightDir + viewDir );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );
		vec3 F = F_Schlick( f0, f90, dotVH );
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
		return F * ( V * D );
	}
#endif
vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {
	vec3 f0 = material.specularColorBlended;
	float f90 = material.specularF90;
	float roughness = material.roughness;
	float alpha = pow2( roughness );
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( f0, f90, dotVH );
	#ifdef USE_IRIDESCENCE
		F = mix( F, material.iridescenceFresnel, material.iridescence );
	#endif
	#ifdef USE_ANISOTROPY
		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );
		float V = V_GGX_SmithCorrelated_Anisotropic( material.alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );
		float D = D_GGX_Anisotropic( material.alphaT, alpha, dotNH, dotTH, dotBH );
	#else
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
	#endif
	return F * ( V * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;
	float dotNV = saturate( dot( N, V ) );
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 );
	mat3 mat = mInv * transpose( mat3( T1, T2, N ) );
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
	return vec3( result );
}
#if defined( USE_SHEEN )
float D_Charlie( float roughness, float dotNH ) {
	float alpha = pow2( roughness );
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 );
	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );
}
float V_Neubelt( float dotNV, float dotNL ) {
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );
}
vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );
	return sheenColor * ( D * V );
}
#endif
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	float r2 = roughness * roughness;
	float rInv = 1.0 / ( roughness + 0.1 );
	float a = -1.9362 + 1.0678 * roughness + 0.4573 * r2 - 0.8469 * rInv;
	float b = -0.6014 + 0.5538 * roughness - 0.4670 * r2 - 0.1255 * rInv;
	float DG = exp( a * dotNV + b );
	return saturate( DG );
}
vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	vec2 fab = texture2D( dfgLUT, vec2( roughness, dotNV ) ).rg;
	return specularColor * fab.x + specularF90 * fab.y;
}
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec2 fab, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec2 fab, const in vec3 specularColor, const in float specularF90, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif
	#ifdef USE_IRIDESCENCE
		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );
	#else
		vec3 Fr = specularColor;
	#endif
	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;
	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;
	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619;	vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
	singleScatter += FssEss;
	multiScatter += Fms * Ems;
}
#if NUM_RECT_AREA_LIGHTS > 0
	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;
		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight;		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;
		vec2 uv = LTC_Uv( normal, viewDir, roughness );
		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );
		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);
		vec3 fresnel = ( material.specularColorBlended * t2.x + ( material.specularF90 - material.specularColorBlended ) * t2.y );
		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );
		reflectedLight.directDiffuse += lightColor * material.diffuseContribution * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );
		#ifdef USE_CLEARCOAT
			vec3 Ncc = geometryClearcoatNormal;
			vec2 uvClearcoat = LTC_Uv( Ncc, viewDir, material.clearcoatRoughness );
			vec4 t1Clearcoat = texture2D( ltc_1, uvClearcoat );
			vec4 t2Clearcoat = texture2D( ltc_2, uvClearcoat );
			mat3 mInvClearcoat = mat3(
				vec3( t1Clearcoat.x, 0, t1Clearcoat.y ),
				vec3(             0, 1,             0 ),
				vec3( t1Clearcoat.z, 0, t1Clearcoat.w )
			);
			vec3 fresnelClearcoat = material.clearcoatF0 * t2Clearcoat.x + ( material.clearcoatF90 - material.clearcoatF0 ) * t2Clearcoat.y;
			clearcoatSpecularDirect += lightColor * fresnelClearcoat * LTC_Evaluate( Ncc, viewDir, position, mInvClearcoat, rectCoords );
		#endif
	}
#endif
void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	#ifdef USE_CLEARCOAT
		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );
		vec3 ccIrradiance = dotNLcc * directLight.color;
		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );
	#endif
	#ifdef USE_SHEEN
 
 		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
 
 		float sheenAlbedoV = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
 		float sheenAlbedoL = IBLSheenBRDF( geometryNormal, directLight.direction, material.sheenRoughness );
 
 		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * max( sheenAlbedoV, sheenAlbedoL );
 
 		irradiance *= sheenEnergyComp;
 
 	#endif
	vec3 specularBRDF = BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );
	#ifdef USE_RETROREFLECTION
		vec3 retroViewDir = reflect( - geometryViewDir, geometryNormal );
		vec3 retroSpecularBRDF = BRDF_GGX( directLight.direction, retroViewDir, geometryNormal, material );
		specularBRDF = mix( specularBRDF, retroSpecularBRDF, saturate( material.retroreflectivity ) );
	#endif
	reflectedLight.directSpecular += irradiance * specularBRDF * material.multiScatteringCompensation;
	vec3 halfDir = normalize( directLight.direction + geometryViewDir );
	float dotVH = saturate( dot( geometryViewDir, halfDir ) );
	vec3 F = F_Schlick( material.specularColor, material.specularF90, dotVH );
	#ifdef USE_RETROREFLECTION
		vec3 retroHalfDir = normalize( directLight.direction + retroViewDir );
		float dotRetroVH = saturate( dot( retroViewDir, retroHalfDir ) );
		vec3 retroF = F_Schlick( material.specularColor, material.specularF90, dotRetroVH );
		F = mix( F, retroF, saturate( material.retroreflectivity ) );
	#endif
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseContribution ) * ( 1.0 - F );
}
void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 singleScattering = vec3( 0.0 );
	vec3 multiScattering = vec3( 0.0 );
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( material.dfg, material.specularColor, material.specularF90, material.iridescence, material.iridescenceF0Dielectric, singleScattering, multiScattering );
	#else
		computeMultiscattering( material.dfg, material.specularColor, material.specularF90, singleScattering, multiScattering );
	#endif
	vec3 diffuse = irradiance * BRDF_Lambert( material.diffuseContribution ) * ( 1.0 - singleScattering - multiScattering );
	#ifdef USE_SHEEN
		float sheenAlbedo = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
		sheenSpecularIndirect += irradiance * material.sheenColor * sheenAlbedo * RECIPROCAL_PI;
		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * sheenAlbedo;
		diffuse *= sheenEnergyComp;
	#endif
	reflectedLight.indirectDiffuse += diffuse;
}
void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
	#ifdef USE_CLEARCOAT
		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness ) * RECIPROCAL_PI;
 	#endif
	vec3 singleScatteringDielectric = vec3( 0.0 );
	vec3 multiScatteringDielectric = vec3( 0.0 );
	vec3 singleScatteringMetallic = vec3( 0.0 );
	vec3 multiScatteringMetallic = vec3( 0.0 );
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( material.dfg, material.specularColor, material.specularF90, material.iridescence, material.iridescenceF0Dielectric, singleScatteringDielectric, multiScatteringDielectric );
		computeMultiscatteringIridescence( material.dfg, material.diffuseColor, material.specularF90, material.iridescence, material.iridescenceF0Metallic, singleScatteringMetallic, multiScatteringMetallic );
	#else
		computeMultiscattering( material.dfg, material.specularColor, material.specularF90, singleScatteringDielectric, multiScatteringDielectric );
		computeMultiscattering( material.dfg, material.diffuseColor, material.specularF90, singleScatteringMetallic, multiScatteringMetallic );
	#endif
	vec3 singleScattering = mix( singleScatteringDielectric, singleScatteringMetallic, material.metalness );
	vec3 multiScattering = mix( multiScatteringDielectric, multiScatteringMetallic, material.metalness );
	vec3 totalScatteringDielectric = singleScatteringDielectric + multiScatteringDielectric;
	vec3 diffuse = material.diffuseContribution * ( 1.0 - totalScatteringDielectric );
	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;
	vec3 indirectSpecular = radiance * singleScattering;
	indirectSpecular += multiScattering * cosineWeightedIrradiance;
	vec3 indirectDiffuse = diffuse * cosineWeightedIrradiance;
	#ifdef USE_SHEEN
		float sheenAlbedo = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * sheenAlbedo;
		indirectSpecular *= sheenEnergyComp;
		indirectDiffuse *= sheenEnergyComp;
	#endif
	reflectedLight.indirectSpecular += indirectSpecular;
	reflectedLight.indirectDiffuse += indirectDiffuse;
}
#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {
	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}`,Lp=`
vec3 geometryPosition = - vViewPosition;
vec3 geometryNormal = normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( vViewPosition );
vec3 geometryClearcoatNormal = vec3( 0.0 );
#ifdef USE_CLEARCOAT
	geometryClearcoatNormal = clearcoatNormal;
#endif
#ifdef USE_IRIDESCENCE
	float dotNVi = saturate( dot( normal, geometryViewDir ) );
	if ( material.iridescenceThickness == 0.0 ) {
		material.iridescence = 0.0;
	} else {
		material.iridescence = saturate( material.iridescence );
	}
	if ( material.iridescence > 0.0 ) {
		vec3 iridescenceFresnelDielectric = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		vec3 iridescenceFresnelMetallic = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.diffuseColor );
		material.iridescenceFresnel = mix( iridescenceFresnelDielectric, iridescenceFresnelMetallic, material.metalness );
		material.iridescenceF0Dielectric = Schlick_to_F0( iridescenceFresnelDielectric, 1.0, dotNVi );
		material.iridescenceF0Metallic = Schlick_to_F0( iridescenceFresnelMetallic, 1.0, dotNVi );
	}
#endif
#ifdef STANDARD
	float dotNVms = saturate( dot( geometryNormal, geometryViewDir ) );
	material.dfg = texture2D( dfgLUT, vec2( material.roughness, dotNVms ) ).rg;
	#if ( NUM_SUN_LIGHTS > 0 || NUM_DIR_LIGHTS > 0 || NUM_POINT_LIGHTS > 0 || NUM_SPOT_LIGHTS > 0 )
		float EssMs = material.dfg.x + material.dfg.y;
		material.multiScatteringCompensation = 1.0 + material.specularColorBlended * ( 1.0 / EssMs - 1.0 );
	#endif
#endif
IncidentLight directLight;
#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )
	PointLight pointLight;
	#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		pointLight = pointLights[ i ];
		getPointLightInfo( pointLight, geometryPosition, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_POINT_LIGHT_SHADOWS ) && ( defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_BASIC ) )
		pointLightShadow = pointLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getPointShadow( pointShadowMap[ i ], pointLightShadow.shadowMapSize, pointLightShadow.shadowIntensity, pointLightShadow.shadowBias, pointLightShadow.shadowRadius, vPointShadowCoord[ i ], pointLightShadow.shadowCameraNear, pointLightShadow.shadowCameraFar ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )
	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;
	#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		spotLight = spotLights[ i ];
		getSpotLightInfo( spotLight, geometryPosition, directLight );
		#if ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#define SPOT_LIGHT_MAP_INDEX UNROLLED_LOOP_INDEX
		#elif ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		#define SPOT_LIGHT_MAP_INDEX NUM_SPOT_LIGHT_MAPS
		#else
		#define SPOT_LIGHT_MAP_INDEX ( UNROLLED_LOOP_INDEX - NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#endif
		#if ( SPOT_LIGHT_MAP_INDEX < NUM_SPOT_LIGHT_MAPS )
			spotLightCoord = vSpotLightCoord[ i ].xyz / vSpotLightCoord[ i ].w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3( 1.0 ) ) );
			spotColor = texture2D( spotLightMap[ SPOT_LIGHT_MAP_INDEX ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		#endif
		#undef SPOT_LIGHT_MAP_INDEX
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		spotLightShadow = spotLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( spotShadowMap[ i ], spotLightShadow.shadowMapSize, spotLightShadow.shadowIntensity, spotLightShadow.shadowBias, spotLightShadow.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SUN_LIGHTS > 0 ) && defined( RE_Direct )
	SunLight sunLight;
	#if defined( USE_SHADOWMAP ) && NUM_SUN_LIGHT_SHADOWS > 0
	SunLightShadow sunLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SUN_LIGHTS; i ++ ) {
		sunLight = sunLights[ i ];
		getSunLightInfo( sunLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SUN_LIGHT_SHADOWS )
		sunLightShadow = sunLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getSunShadow( sunShadowMap[ i ], sunLightShadow, UNROLLED_LOOP_INDEX ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )
	DirectionalLight directionalLight;
	#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		directionalLight = directionalLights[ i ];
		getDirectionalLightInfo( directionalLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_DIR_LIGHT_SHADOWS )
		directionalLightShadow = directionalLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( directionalShadowMap[ i ], directionalLightShadow.shadowMapSize, directionalLightShadow.shadowIntensity, directionalLightShadow.shadowBias, directionalLightShadow.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )
	RectAreaLight rectAreaLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {
		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if defined( RE_IndirectDiffuse )
	vec3 iblIrradiance = vec3( 0.0 );
	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );
	#if defined( USE_LIGHT_PROBES )
		irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );
	#endif
	#if ( NUM_HEMI_LIGHTS > 0 )
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {
			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometryNormal );
		}
		#pragma unroll_loop_end
	#endif
	#ifdef USE_LIGHT_PROBES_GRID
		vec3 probeWorldPos = ( ( vec4( geometryPosition, 1.0 ) - viewMatrix[ 3 ] ) * viewMatrix ).xyz;
		vec3 probeWorldNormal = transformNormalByInverseViewMatrix( geometryNormal, viewMatrix );
		irradiance += getLightProbeGridIrradiance( probeWorldPos, probeWorldNormal );
	#endif
#endif
#if defined( RE_IndirectSpecular )
	vec3 radiance = vec3( 0.0 );
	vec3 clearcoatRadiance = vec3( 0.0 );
#endif`,Np=`#if defined( RE_IndirectDiffuse )
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
		irradiance += lightMapIrradiance;
	#endif
	#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_CUBE_UV )
		#if defined( STANDARD ) || defined( LAMBERT ) || defined( PHONG )
			iblIrradiance += getIBLIrradiance( geometryNormal );
		#endif
	#endif
#endif
#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )
	#ifdef USE_ANISOTROPY
		vec3 iblRadiance = getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
	#else
		vec3 iblRadiance = getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );
	#endif
	#ifdef USE_RETROREFLECTION
		#ifdef USE_ANISOTROPY
			vec3 retroIBLRadiance = getIBLAnisotropyRetroRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
		#else
			vec3 retroIBLRadiance = getIBLRetroRadiance( geometryViewDir, geometryNormal, material.roughness );
		#endif
		iblRadiance = mix( iblRadiance, retroIBLRadiance, saturate( material.retroreflectivity ) );
	#endif
	radiance += iblRadiance;
	#ifdef USE_CLEARCOAT
		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );
	#endif
#endif`,Dp=`#if defined( RE_IndirectDiffuse )
	#if defined( LAMBERT ) || defined( PHONG )
		irradiance += iblIrradiance;
	#endif
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,Op=`#ifdef USE_LIGHT_PROBES_GRID
uniform highp sampler3D probesSH;
uniform vec3 probesMin;
uniform vec3 probesMax;
uniform vec3 probesResolution;
vec3 getLightProbeGridIrradiance( vec3 worldPos, vec3 worldNormal ) {
	vec3 res = probesResolution;
	vec3 gridRange = probesMax - probesMin;
	vec3 resMinusOne = res - 1.0;
	vec3 probeSpacing = gridRange / resMinusOne;
	vec3 samplePos = worldPos + worldNormal * probeSpacing * 0.5;
	vec3 uvw = clamp( ( samplePos - probesMin ) / gridRange, 0.0, 1.0 );
	uvw = uvw * resMinusOne / res + 0.5 / res;
	float nz          = res.z;
	float paddedSlices = nz + 2.0;
	float atlasDepth  = 7.0 * paddedSlices;
	float uvZBase     = uvw.z * nz + 1.0;
	vec4 s0 = texture( probesSH, vec3( uvw.xy, ( uvZBase                       ) / atlasDepth ) );
	vec4 s1 = texture( probesSH, vec3( uvw.xy, ( uvZBase +       paddedSlices   ) / atlasDepth ) );
	vec4 s2 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 2.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s3 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 3.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s4 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 4.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s5 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 5.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s6 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 6.0 * paddedSlices   ) / atlasDepth ) );
	vec3 c0 = s0.xyz;
	vec3 c1 = vec3( s0.w, s1.xy );
	vec3 c2 = vec3( s1.zw, s2.x );
	vec3 c3 = s2.yzw;
	vec3 c4 = s3.xyz;
	vec3 c5 = vec3( s3.w, s4.xy );
	vec3 c6 = vec3( s4.zw, s5.x );
	vec3 c7 = s5.yzw;
	vec3 c8 = s6.xyz;
	float x = worldNormal.x, y = worldNormal.y, z = worldNormal.z;
	vec3 result = c0 * 0.886227;
	result += c1 * 2.0 * 0.511664 * y;
	result += c2 * 2.0 * 0.511664 * z;
	result += c3 * 2.0 * 0.511664 * x;
	result += c4 * 2.0 * 0.429043 * x * y;
	result += c5 * 2.0 * 0.429043 * y * z;
	result += c6 * ( 0.743125 * z * z - 0.247708 );
	result += c7 * 2.0 * 0.429043 * x * z;
	result += c8 * 0.429043 * ( x * x - y * y );
	return max( result, vec3( 0.0 ) );
}
#endif`,Up=`#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
	gl_FragDepth = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,Fp=`#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,Bp=`#ifdef USE_LOGARITHMIC_DEPTH_BUFFER
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,kp=`#ifdef USE_LOGARITHMIC_DEPTH_BUFFER
	vFragDepth = 1.0 + gl_Position.w;
	vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
#endif`,Vp=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = sRGBTransferEOTF( sampledDiffuseColor );
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,Gp=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,Hp=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
	#if defined( USE_POINTS_UV )
		vec2 uv = vUv;
	#else
		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	#endif
#endif
#ifdef USE_MAP
	diffuseColor *= texture2D( map, uv );
#endif
#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, uv ).g;
#endif`,Wp=`#if defined( USE_POINTS_UV )
	varying vec2 vUv;
#else
	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
		uniform mat3 uvTransform;
	#endif
#endif
#ifdef USE_MAP
	uniform sampler2D map;
#endif
#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,Xp=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,qp=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,Yp=`#ifdef USE_INSTANCING_MORPH
	float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	float morphTargetBaseInfluence = texelFetch( morphTexture, ivec2( 0, gl_InstanceID ), 0 ).r;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		morphTargetInfluences[i] =  texelFetch( morphTexture, ivec2( i + 1, gl_InstanceID ), 0 ).r;
	}
#endif`,Zp=`#if defined( USE_MORPHCOLORS )
	vColor *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,Kp=`#ifdef USE_MORPHNORMALS
	objectNormal *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,Jp=`#ifdef USE_MORPHTARGETS
	#ifndef USE_INSTANCING_MORPH
		uniform float morphTargetBaseInfluence;
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	#endif
	uniform sampler2DArray morphTargetsTexture;
	uniform ivec2 morphTargetsTextureSize;
	vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
		int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
		int y = texelIndex / morphTargetsTextureSize.x;
		int x = texelIndex - y * morphTargetsTextureSize.x;
		ivec3 morphUV = ivec3( x, y, morphTargetIndex );
		return texelFetch( morphTargetsTexture, morphUV, 0 );
	}
#endif`,$p=`#ifdef USE_MORPHTARGETS
	transformed *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,jp=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );
#else
	vec3 normal = normalize( vNormal );
	#ifdef DOUBLE_SIDED
		normal *= faceDirection;
	#endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
	#ifdef USE_TANGENT
		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);
	#endif
	#ifdef DOUBLE_SIDED
		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;
	#endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	#ifdef USE_TANGENT
		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
	#endif
	#ifdef DOUBLE_SIDED
		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;
	#endif
#endif
vec3 nonPerturbedNormal = normal;`,Qp=`#ifdef USE_NORMALMAP_OBJECTSPACE
	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#ifdef FLIP_SIDED
		normal = - normal;
	#endif
	#ifdef DOUBLE_SIDED
		normal = normal * faceDirection;
	#endif
	normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#if defined( USE_PACKED_NORMALMAP )
		mapN = vec3( mapN.xy, sqrt( saturate( 1.0 - dot( mapN.xy, mapN.xy ) ) ) );
	#endif
	mapN.xy *= normalScale;
	normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif`,e0=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,t0=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,n0=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
		#ifdef FLIP_SIDED
			vBitangent = - vBitangent;
		#endif
	#endif
#endif`,i0=`#ifdef USE_NORMALMAP
	uniform sampler2D normalMap;
	uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
	uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
	mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
		vec3 q0 = dFdx( eye_pos.xyz );
		vec3 q1 = dFdy( eye_pos.xyz );
		vec2 st0 = dFdx( uv.st );
		vec2 st1 = dFdy( uv.st );
		vec3 N = surf_norm;
		vec3 q1perp = cross( q1, N );
		vec3 q0perp = cross( N, q0 );
		vec3 T = q1perp * st0.x + q0perp * st1.x;
		vec3 B = q1perp * st0.y + q0perp * st1.y;
		float det = max( dot( T, T ), dot( B, B ) );
		float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
		return mat3( T * scale, B * scale, N );
	}
#endif`,s0=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,r0=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,a0=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,o0=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,c0=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,l0=`vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}
vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}
const float PackUpscale = 256. / 255.;const float UnpackDownscale = 255. / 256.;const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;
const vec4 PackFactors = vec4( 1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0 );
const vec2 UnpackFactors2 = vec2( UnpackDownscale, 1.0 / PackFactors.g );
const vec3 UnpackFactors3 = vec3( UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b );
const vec4 UnpackFactors4 = vec4( UnpackDownscale / PackFactors.rgb, 1.0 / PackFactors.a );
vec4 packDepthToRGBA( const in float v ) {
	if( v <= 0.0 )
		return vec4( 0., 0., 0., 0. );
	if( v >= 1.0 )
		return vec4( 1., 1., 1., 1. );
	float vuf;
	float af = modf( v * PackFactors.a, vuf );
	float bf = modf( vuf * ShiftRight8, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec4( vuf * Inv255, gf * PackUpscale, bf * PackUpscale, af );
}
vec3 packDepthToRGB( const in float v ) {
	if( v <= 0.0 )
		return vec3( 0., 0., 0. );
	if( v >= 1.0 )
		return vec3( 1., 1., 1. );
	float vuf;
	float bf = modf( v * PackFactors.b, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec3( vuf * Inv255, gf * PackUpscale, bf );
}
vec2 packDepthToRG( const in float v ) {
	if( v <= 0.0 )
		return vec2( 0., 0. );
	if( v >= 1.0 )
		return vec2( 1., 1. );
	float vuf;
	float gf = modf( v * 256., vuf );
	return vec2( vuf * Inv255, gf );
}
float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors4 );
}
float unpackRGBToDepth( const in vec3 v ) {
	return dot( v, UnpackFactors3 );
}
float unpackRGToDepth( const in vec2 v ) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}
vec4 pack2HalfToRGBA( const in vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}
vec2 unpackRGBATo2Half( const in vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}
float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {
	#ifdef USE_REVERSED_DEPTH_BUFFER
	
		return depth * ( far - near ) - far;
	#else
		return depth * ( near - far ) - near;
	#endif
}
float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return ( ( near + viewZ ) * far ) / ( ( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	
	#ifdef USE_REVERSED_DEPTH_BUFFER
		return ( near * far ) / ( ( near - far ) * depth - near );
	#else
		return ( near * far ) / ( ( far - near ) * depth - far );
	#endif
}`,h0=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,u0=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,f0=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,d0=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,p0=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,m0=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,M0=`#if NUM_SPOT_LIGHT_COORDS > 0
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#if NUM_SPOT_LIGHT_MAPS > 0
	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_SUN_LIGHT_SHADOWS > 0
		#define SUN_LIGHT_CASCADES 2
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform sampler2DShadow sunShadowMap[ NUM_SUN_LIGHT_SHADOWS ];
		#else
			uniform sampler2D sunShadowMap[ NUM_SUN_LIGHT_SHADOWS ];
		#endif
		uniform mat4 sunShadowMatrix[ NUM_SUN_LIGHT_SHADOWS * SUN_LIGHT_CASCADES ];
		uniform vec4 sunShadowCascade[ NUM_SUN_LIGHT_SHADOWS * SUN_LIGHT_CASCADES ];
		varying vec4 vSunShadowWorldPosition;
		varying vec3 vSunShadowWorldNormal;
		struct SunLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SunLightShadow sunLightShadows[ NUM_SUN_LIGHT_SHADOWS ];
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform sampler2DShadow directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#else
			uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#endif
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform sampler2DShadow spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		#else
			uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		#endif
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform samplerCubeShadow pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		#elif defined( SHADOWMAP_TYPE_BASIC )
			uniform samplerCube pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		#endif
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
	#if defined( SHADOWMAP_TYPE_PCF )
		float interleavedGradientNoise( vec2 position ) {
			return fract( 52.9829189 * fract( dot( position, vec2( 0.06711056, 0.00583715 ) ) ) );
		}
		vec2 vogelDiskSample( int sampleIndex, int samplesCount, float phi ) {
			const float goldenAngle = 2.399963229728653;
			float r = sqrt( ( float( sampleIndex ) + 0.5 ) / float( samplesCount ) );
			float theta = float( sampleIndex ) * goldenAngle + phi;
			return vec2( cos( theta ), sin( theta ) ) * r;
		}
	#endif
	#if defined( SHADOWMAP_TYPE_PCF )
		float getShadow( sampler2DShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
			float shadow = 1.0;
			shadowCoord.xyz /= shadowCoord.w;
			shadowCoord.z += shadowBias;
			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
			if ( frustumTest ) {
				vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
				float radius = shadowRadius * texelSize.x;
				float phi = interleavedGradientNoise( gl_FragCoord.xy ) * PI2;
				shadow = (
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 0, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 1, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 2, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 3, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 4, 5, phi ) * radius, shadowCoord.z ) )
				) * 0.2;
			}
			return mix( 1.0, shadow, shadowIntensity );
		}
	#elif defined( SHADOWMAP_TYPE_VSM )
		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
			float shadow = 1.0;
			shadowCoord.xyz /= shadowCoord.w;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				shadowCoord.z -= shadowBias;
			#else
				shadowCoord.z += shadowBias;
			#endif
			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
			if ( frustumTest ) {
				vec2 distribution = texture2D( shadowMap, shadowCoord.xy ).rg;
				float mean = distribution.x;
				float variance = distribution.y * distribution.y;
				#ifdef USE_REVERSED_DEPTH_BUFFER
					float hard_shadow = step( mean, shadowCoord.z );
				#else
					float hard_shadow = step( shadowCoord.z, mean );
				#endif
				
				if ( hard_shadow == 1.0 ) {
					shadow = 1.0;
				} else {
					variance = max( variance, 0.0000001 );
					float d = shadowCoord.z - mean;
					float p_max = variance / ( variance + d * d );
					p_max = clamp( ( p_max - 0.3 ) / 0.65, 0.0, 1.0 );
					shadow = max( hard_shadow, p_max );
				}
			}
			return mix( 1.0, shadow, shadowIntensity );
		}
	#else
		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
			float shadow = 1.0;
			shadowCoord.xyz /= shadowCoord.w;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				shadowCoord.z -= shadowBias;
			#else
				shadowCoord.z += shadowBias;
			#endif
			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
			if ( frustumTest ) {
				float depth = texture2D( shadowMap, shadowCoord.xy ).r;
				#ifdef USE_REVERSED_DEPTH_BUFFER
					shadow = step( depth, shadowCoord.z );
				#else
					shadow = step( shadowCoord.z, depth );
				#endif
			}
			return mix( 1.0, shadow, shadowIntensity );
		}
	#endif
	#if NUM_SUN_LIGHT_SHADOWS > 0
		float getSunShadow(
			#if defined( SHADOWMAP_TYPE_PCF )
				sampler2DShadow shadowMap,
			#else
				sampler2D shadowMap,
			#endif
			SunLightShadow sunLightShadow,
			int shadowIndex
		) {
			vec4 shadowWorldPosition = vec4( vSunShadowWorldPosition.xyz + vSunShadowWorldNormal * sunLightShadow.shadowNormalBias, 1.0 );
			float viewDepth = vSunShadowWorldPosition.w;
			int cascadeOffset = shadowIndex * SUN_LIGHT_CASCADES;
			float shadow = 1.0;
			for ( int i = SUN_LIGHT_CASCADES - 1; i >= 0; i -- ) {
				vec4 cascade = sunShadowCascade[ cascadeOffset + i ];
				if ( viewDepth >= cascade.x && viewDepth < cascade.y ) {
					float cascadeShadow = getShadow(
						shadowMap,
						sunLightShadow.shadowMapSize,
						sunLightShadow.shadowIntensity,
						sunLightShadow.shadowBias,
						sunLightShadow.shadowRadius,
						sunShadowMatrix[ cascadeOffset + i ] * shadowWorldPosition
					);
					shadow = mix( cascadeShadow, shadow, smoothstep( cascade.z, cascade.y, viewDepth ) );
				}
			}
			return shadow;
		}
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
	#if defined( SHADOWMAP_TYPE_PCF )
	float getPointShadow( samplerCubeShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		float shadow = 1.0;
		vec3 lightToPosition = shadowCoord.xyz;
		vec3 bd3D = normalize( lightToPosition );
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );
		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {
			#ifdef USE_REVERSED_DEPTH_BUFFER
				float dp = ( shadowCameraNear * ( shadowCameraFar - viewSpaceZ ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
				dp -= shadowBias;
			#else
				float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
				dp += shadowBias;
			#endif
			float texelSize = shadowRadius / shadowMapSize.x;
			vec3 absDir = abs( bd3D );
			vec3 tangent = absDir.x > absDir.z ? vec3( 0.0, 1.0, 0.0 ) : vec3( 1.0, 0.0, 0.0 );
			tangent = normalize( cross( bd3D, tangent ) );
			vec3 bitangent = cross( bd3D, tangent );
			float phi = interleavedGradientNoise( gl_FragCoord.xy ) * PI2;
			vec2 sample0 = vogelDiskSample( 0, 5, phi );
			vec2 sample1 = vogelDiskSample( 1, 5, phi );
			vec2 sample2 = vogelDiskSample( 2, 5, phi );
			vec2 sample3 = vogelDiskSample( 3, 5, phi );
			vec2 sample4 = vogelDiskSample( 4, 5, phi );
			shadow = (
				texture( shadowMap, vec4( bd3D + ( tangent * sample0.x + bitangent * sample0.y ) * texelSize, dp ) ) +
				texture( shadowMap, vec4( bd3D + ( tangent * sample1.x + bitangent * sample1.y ) * texelSize, dp ) ) +
				texture( shadowMap, vec4( bd3D + ( tangent * sample2.x + bitangent * sample2.y ) * texelSize, dp ) ) +
				texture( shadowMap, vec4( bd3D + ( tangent * sample3.x + bitangent * sample3.y ) * texelSize, dp ) ) +
				texture( shadowMap, vec4( bd3D + ( tangent * sample4.x + bitangent * sample4.y ) * texelSize, dp ) )
			) * 0.2;
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
	#elif defined( SHADOWMAP_TYPE_BASIC )
	float getPointShadow( samplerCube shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		float shadow = 1.0;
		vec3 lightToPosition = shadowCoord.xyz;
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );
		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {
			float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
			dp += shadowBias;
			vec3 bd3D = normalize( lightToPosition );
			float depth = textureCube( shadowMap, bd3D ).r;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				depth = 1.0 - depth;
			#endif
			shadow = step( dp, depth );
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
	#endif
	#endif
#endif`,g0=`#if NUM_SPOT_LIGHT_COORDS > 0
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_SUN_LIGHT_SHADOWS > 0
		varying vec4 vSunShadowWorldPosition;
		varying vec3 vSunShadowWorldNormal;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
#endif`,_0=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_SUN_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
	#ifdef HAS_NORMAL
		vec3 shadowWorldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );
	#else
		vec3 shadowWorldNormal = vec3( 0.0 );
	#endif
	vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
	#if NUM_SUN_LIGHT_SHADOWS > 0
		vSunShadowWorldPosition = vec4( worldPosition.xyz, - mvPosition.z );
		vSunShadowWorldNormal = shadowWorldNormal;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * directionalLightShadows[ i ].shadowNormalBias, 0 );
			vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * pointLightShadows[ i ].shadowNormalBias, 0 );
			vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_COORDS; i ++ ) {
		shadowWorldPosition = worldPosition;
		#if ( defined( USE_SHADOWMAP ) && UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
			shadowWorldPosition.xyz += shadowWorldNormal * spotLightShadows[ i ].shadowNormalBias;
		#endif
		vSpotLightCoord[ i ] = spotLightMatrix[ i ] * shadowWorldPosition;
	}
	#pragma unroll_loop_end
#endif`,x0=`float getShadowMask() {
	float shadow = 1.0;
	#ifdef USE_SHADOWMAP
	#if NUM_SUN_LIGHT_SHADOWS > 0
	SunLightShadow sunLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SUN_LIGHT_SHADOWS; i ++ ) {
		sunLight = sunLightShadows[ i ];
		shadow *= receiveShadow ? getSunShadow( sunShadowMap[ i ], sunLight, UNROLLED_LOOP_INDEX ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
		directionalLight = directionalLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowIntensity, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_SHADOWS; i ++ ) {
		spotLight = spotLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowIntensity, spotLight.shadowBias, spotLight.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0 && ( defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_BASIC ) )
	PointLightShadow pointLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
		pointLight = pointLightShadows[ i ];
		shadow *= receiveShadow ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowIntensity, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#endif
	return shadow;
}`,y0=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,v0=`#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	uniform highp sampler2D boneTexture;
	mat4 getBoneMatrix( const in float i ) {
		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,b0=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,S0=`#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif`,w0=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,T0=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,E0=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,A0=`#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
vec3 LinearToneMapping( vec3 color ) {
	return saturate( toneMappingExposure * color );
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
vec3 CineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 RRTAndODTFit( vec3 v ) {
	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ),		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ),		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);
	color *= toneMappingExposure / 0.6;
	color = ACESInputMat * color;
	color = RRTAndODTFit( color );
	color = ACESOutputMat * color;
	return saturate( color );
}
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);
const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);
vec3 agxDefaultContrastApprox( vec3 x ) {
	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;
	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;
}
vec3 AgXToneMapping( vec3 color ) {
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);
	const float AgxMinEv = - 12.47393;	const float AgxMaxEv = 4.026069;
	color *= toneMappingExposure;
	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
	color = AgXInsetMatrix * color;
	color = max( color, 1e-10 );	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
	color = clamp( color, 0.0, 1.0 );
	color = agxDefaultContrastApprox( color );
	color = AgXOutsetMatrix * color;
	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
	color = clamp( color, 0.0, 1.0 );
	return color;
}
vec3 NeutralToneMapping( vec3 color ) {
	const float StartCompression = 0.8 - 0.04;
	const float Desaturation = 0.15;
	color *= toneMappingExposure;
	float x = min( color.r, min( color.g, color.b ) );
	float offset = x < 0.08 ? x - 6.25 * x * x : 0.04;
	color -= offset;
	float peak = max( color.r, max( color.g, color.b ) );
	if ( peak < StartCompression ) return color;
	float d = 1. - StartCompression;
	float newPeak = 1. - d * d / ( peak + d - StartCompression );
	color *= newPeak / peak;
	float g = 1. - 1. / ( Desaturation * ( peak - newPeak ) + 1. );
	return mix( color, vec3( newPeak ), g );
}
vec3 CustomToneMapping( vec3 color ) { return color; }`,R0=`#ifdef USE_TRANSMISSION
	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;
	#endif
	#ifdef USE_THICKNESSMAP
		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;
	#endif
	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = transformNormalByInverseViewMatrix( normal, viewMatrix );
	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseContribution, material.specularColorBlended, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.dispersion, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );
	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );
	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );
#endif`,C0=`#ifdef USE_TRANSMISSION
	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		uniform sampler2D transmissionMap;
	#endif
	#ifdef USE_THICKNESSMAP
		uniform sampler2D thicknessMap;
	#endif
	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;
	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;
	varying vec3 vWorldPosition;
	float w0( float a ) {
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );
	}
	float w1( float a ) {
		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );
	}
	float w2( float a ){
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );
	}
	float w3( float a ) {
		return ( 1.0 / 6.0 ) * ( a * a * a );
	}
	float g0( float a ) {
		return w0( a ) + w1( a );
	}
	float g1( float a ) {
		return w2( a ) + w3( a );
	}
	float h0( float a ) {
		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );
	}
	float h1( float a ) {
		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );
	}
	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {
		uv = uv * texelSize.zw + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );
		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );
	}
	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {
		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );
	}
	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );
		return normalize( refractionVector ) * thickness * modelScale;
	}
	float applyIorToRoughness( const in float roughness, const in float ior ) {
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );
	}
	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {
		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );
	}
	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {
		if ( isinf( attenuationDistance ) ) {
			return vec3( 1.0 );
		} else {
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance );			return transmittance;
		}
	}
	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float dispersion, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {
		vec4 transmittedLight;
		vec3 transmittance;
		#ifdef USE_DISPERSION
			float halfSpread = ( ior - 1.0 ) * 0.025 * dispersion;
			vec3 iors = vec3( ior - halfSpread, ior, ior + halfSpread );
			for ( int i = 0; i < 3; i ++ ) {
				vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, iors[ i ], modelMatrix );
				vec3 refractedRayExit = position + transmissionRay;
				vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
				vec2 refractionCoords = ndcPos.xy / ndcPos.w;
				refractionCoords += 1.0;
				refractionCoords /= 2.0;
				vec4 transmissionSample = getTransmissionSample( refractionCoords, roughness, iors[ i ] );
				transmittedLight[ i ] = transmissionSample[ i ];
				transmittedLight.a += transmissionSample.a;
				transmittance[ i ] = diffuseColor[ i ] * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance )[ i ];
			}
			transmittedLight.a /= 3.0;
		#else
			vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
			vec3 refractedRayExit = position + transmissionRay;
			vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
			vec2 refractionCoords = ndcPos.xy / ndcPos.w;
			refractionCoords += 1.0;
			refractionCoords /= 2.0;
			transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
			transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );
		#endif
		vec3 attenuatedColor = transmittance * transmittedLight.rgb;
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;
		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );
	}
#endif`,z0=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,I0=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	uniform mat3 mapTransform;
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	uniform mat3 alphaMapTransform;
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	uniform mat3 lightMapTransform;
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	uniform mat3 aoMapTransform;
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	uniform mat3 bumpMapTransform;
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	uniform mat3 normalMapTransform;
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_DISPLACEMENTMAP
	uniform mat3 displacementMapTransform;
	varying vec2 vDisplacementMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	uniform mat3 emissiveMapTransform;
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	uniform mat3 metalnessMapTransform;
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	uniform mat3 roughnessMapTransform;
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	uniform mat3 anisotropyMapTransform;
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	uniform mat3 clearcoatMapTransform;
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform mat3 clearcoatNormalMapTransform;
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform mat3 clearcoatRoughnessMapTransform;
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	uniform mat3 sheenColorMapTransform;
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	uniform mat3 sheenRoughnessMapTransform;
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	uniform mat3 iridescenceMapTransform;
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform mat3 iridescenceThicknessMapTransform;
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SPECULARMAP
	uniform mat3 specularMapTransform;
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	uniform mat3 specularColorMapTransform;
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	uniform mat3 specularIntensityMapTransform;
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,P0=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	vUv = vec3( uv, 1 ).xy;
#endif
#ifdef USE_MAP
	vMapUv = ( mapTransform * vec3( MAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ALPHAMAP
	vAlphaMapUv = ( alphaMapTransform * vec3( ALPHAMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_LIGHTMAP
	vLightMapUv = ( lightMapTransform * vec3( LIGHTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_AOMAP
	vAoMapUv = ( aoMapTransform * vec3( AOMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_BUMPMAP
	vBumpMapUv = ( bumpMapTransform * vec3( BUMPMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_NORMALMAP
	vNormalMapUv = ( normalMapTransform * vec3( NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DISPLACEMENTMAP
	vDisplacementMapUv = ( displacementMapTransform * vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_EMISSIVEMAP
	vEmissiveMapUv = ( emissiveMapTransform * vec3( EMISSIVEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_METALNESSMAP
	vMetalnessMapUv = ( metalnessMapTransform * vec3( METALNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ROUGHNESSMAP
	vRoughnessMapUv = ( roughnessMapTransform * vec3( ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ANISOTROPYMAP
	vAnisotropyMapUv = ( anisotropyMapTransform * vec3( ANISOTROPYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOATMAP
	vClearcoatMapUv = ( clearcoatMapTransform * vec3( CLEARCOATMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	vClearcoatNormalMapUv = ( clearcoatNormalMapTransform * vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	vClearcoatRoughnessMapUv = ( clearcoatRoughnessMapTransform * vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCEMAP
	vIridescenceMapUv = ( iridescenceMapTransform * vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	vIridescenceThicknessMapUv = ( iridescenceThicknessMapTransform * vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_COLORMAP
	vSheenColorMapUv = ( sheenColorMapTransform * vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	vSheenRoughnessMapUv = ( sheenRoughnessMapTransform * vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULARMAP
	vSpecularMapUv = ( specularMapTransform * vec3( SPECULARMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_COLORMAP
	vSpecularColorMapUv = ( specularColorMapTransform * vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	vSpecularIntensityMapUv = ( specularIntensityMapTransform * vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_TRANSMISSIONMAP
	vTransmissionMapUv = ( transmissionMapTransform * vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_THICKNESSMAP
	vThicknessMapUv = ( thicknessMapTransform * vec3( THICKNESSMAP_UV, 1 ) ).xy;
#endif`,L0=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`,N0=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,D0=`uniform sampler2D t2D;
uniform float backgroundIntensity;
varying vec2 vUv;
void main() {
	vec4 texColor = texture2D( t2D, vUv );
	#ifdef DECODE_VIDEO_TEXTURE
		texColor = vec4( mix( pow( texColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), texColor.rgb * 0.0773993808, vec3( lessThanEqual( texColor.rgb, vec3( 0.04045 ) ) ) ), texColor.w );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,O0=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,U0=`#ifdef ENVMAP_TYPE_CUBE
	uniform samplerCube envMap;
#elif defined( ENVMAP_TYPE_CUBE_UV )
	uniform sampler2D envMap;
#endif
uniform float backgroundBlurriness;
uniform float backgroundIntensity;
uniform mat3 backgroundRotation;
varying vec3 vWorldDirection;
#include <cube_uv_reflection_fragment>
void main() {
	#ifdef ENVMAP_TYPE_CUBE
		vec4 texColor = textureCube( envMap, backgroundRotation * vWorldDirection );
	#elif defined( ENVMAP_TYPE_CUBE_UV )
		vec4 texColor = textureCubeUV( envMap, backgroundRotation * vWorldDirection, backgroundBlurriness );
	#else
		vec4 texColor = vec4( 0.0, 0.0, 0.0, 1.0 );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,F0=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,B0=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,k0=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
varying vec2 vHighPrecisionZW;
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vHighPrecisionZW = gl_Position.zw;
}`,V0=`#if DEPTH_PACKING == 3200
	uniform float opacity;
#endif
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
varying vec2 vHighPrecisionZW;
void main() {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#if DEPTH_PACKING == 3200
		diffuseColor.a = opacity;
	#endif
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <logdepthbuf_fragment>
	#ifdef USE_REVERSED_DEPTH_BUFFER
		float fragCoordZ = vHighPrecisionZW[ 0 ] / vHighPrecisionZW[ 1 ];
	#else
		float fragCoordZ = 0.5 * vHighPrecisionZW[ 0 ] / vHighPrecisionZW[ 1 ] + 0.5;
	#endif
	#if DEPTH_PACKING == 3200
		gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );
	#elif DEPTH_PACKING == 3201
		gl_FragColor = packDepthToRGBA( fragCoordZ );
	#elif DEPTH_PACKING == 3202
		gl_FragColor = vec4( packDepthToRGB( fragCoordZ ), 1.0 );
	#elif DEPTH_PACKING == 3203
		gl_FragColor = vec4( packDepthToRG( fragCoordZ ), 0.0, 1.0 );
	#endif
}`,G0=`#define DISTANCE
varying vec3 vWorldPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	vWorldPosition = worldPosition.xyz;
}`,H0=`#define DISTANCE
uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist );
	gl_FragColor = vec4( dist, 0.0, 0.0, 1.0 );
}`,W0=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,X0=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,q0=`uniform float scale;
attribute float lineDistance;
varying float vLineDistance;
#include <common>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	vLineDistance = scale * lineDistance;
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,Y0=`uniform vec3 diffuse;
uniform float opacity;
uniform float dashSize;
uniform float totalSize;
varying float vLineDistance;
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	if ( mod( vLineDistance, totalSize ) > dashSize ) {
		discard;
	}
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,Z0=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#if defined ( USE_ENVMAP ) || defined ( USE_SKINNING )
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinbase_vertex>
		#include <skinnormal_vertex>
		#include <defaultnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>
}`,K0=`uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
	varying vec3 vNormal;
#endif
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
	#else
		reflectedLight.indirectDiffuse += vec3( 1.0 );
	#endif
	#include <aomap_fragment>
	reflectedLight.indirectDiffuse *= diffuseColor.rgb;
	vec3 outgoingLight = reflectedLight.indirectDiffuse;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,J0=`#define LAMBERT
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,$0=`#define LAMBERT
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_lambert_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,j0=`#define MATCAP
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
	vViewPosition = - mvPosition.xyz;
}`,Q0=`#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
	#ifdef USE_MATCAP
		vec4 matcapColor = texture2D( matcap, uv );
	#else
		vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
	#endif
	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,em=`#define NORMAL
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	vViewPosition = - mvPosition.xyz;
#endif
}`,tm=`#define NORMAL
uniform float opacity;
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <uv_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( 0.0, 0.0, 0.0, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	gl_FragColor = vec4( normalize( normal ) * 0.5 + 0.5, diffuseColor.a );
	#ifdef OPAQUE
		gl_FragColor.a = 1.0;
	#endif
}`,nm=`#define PHONG
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,im=`#define PHONG
uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,sm=`#define STANDARD
varying vec3 vViewPosition;
#ifdef USE_TRANSMISSION
	varying vec3 vWorldPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
#ifdef USE_TRANSMISSION
	vWorldPosition = worldPosition.xyz;
#endif
}`,rm=`#define STANDARD
#ifdef PHYSICAL
	#define IOR
	#define USE_SPECULAR
#endif
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
#ifdef IOR
	uniform float ior;
#endif
#ifdef USE_SPECULAR
	uniform float specularIntensity;
	uniform vec3 specularColor;
	#ifdef USE_SPECULAR_COLORMAP
		uniform sampler2D specularColorMap;
	#endif
	#ifdef USE_SPECULAR_INTENSITYMAP
		uniform sampler2D specularIntensityMap;
	#endif
#endif
#ifdef USE_CLEARCOAT
	uniform float clearcoat;
	uniform float clearcoatRoughness;
#endif
#ifdef USE_DISPERSION
	uniform float dispersion;
#endif
#ifdef USE_RETROREFLECTION
	uniform float retroreflectivity;
#endif
#ifdef USE_IRIDESCENCE
	uniform float iridescence;
	uniform float iridescenceIOR;
	uniform float iridescenceThicknessMinimum;
	uniform float iridescenceThicknessMaximum;
#endif
#ifdef USE_SHEEN
	uniform vec3 sheenColor;
	uniform float sheenRoughness;
	#ifdef USE_SHEEN_COLORMAP
		uniform sampler2D sheenColorMap;
	#endif
	#ifdef USE_SHEEN_ROUGHNESSMAP
		uniform sampler2D sheenRoughnessMap;
	#endif
#endif
#ifdef USE_ANISOTROPY
	uniform vec2 anisotropyVector;
	#ifdef USE_ANISOTROPYMAP
		uniform sampler2D anisotropyMap;
	#endif
#endif
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <iridescence_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <transmission_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <clearcoat_pars_fragment>
#include <iridescence_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <clearcoat_normal_fragment_begin>
	#include <clearcoat_normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
	vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;
	#include <transmission_fragment>
	vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;
	#ifdef USE_SHEEN
 
		outgoingLight = outgoingLight + sheenSpecularDirect + sheenSpecularIndirect;
 
 	#endif
	#ifdef USE_CLEARCOAT
		float dotNVcc = saturate( dot( geometryClearcoatNormal, geometryViewDir ) );
		vec3 Fcc = F_Schlick( material.clearcoatF0, material.clearcoatF90, dotNVcc );
		outgoingLight = outgoingLight * ( 1.0 - material.clearcoat * Fcc ) + ( clearcoatSpecularDirect + clearcoatSpecularIndirect ) * material.clearcoat;
	#endif
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,am=`#define TOON
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,om=`#define TOON
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_toon_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_toon_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,cm=`uniform float size;
uniform float scale;
#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
#ifdef USE_POINTS_UV
	varying vec2 vUv;
	uniform mat3 uvTransform;
#endif
void main() {
	#ifdef USE_POINTS_UV
		vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	#endif
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	gl_PointSize = size;
	#ifdef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
	#endif
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>
}`,lm=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,hm=`#include <common>
#include <batching_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <shadowmap_pars_vertex>
void main() {
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,um=`uniform vec3 color;
uniform float opacity;
#include <common>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <logdepthbuf_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
void main() {
	#include <logdepthbuf_fragment>
	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,fm=`uniform float rotation;
uniform vec2 center;
#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	vec4 mvPosition = modelViewMatrix[ 3 ];
	vec2 scale = vec2( length( modelMatrix[ 0 ].xyz ), length( modelMatrix[ 1 ].xyz ) );
	#ifndef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) scale *= - mvPosition.z;
	#endif
	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;
	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;
	mvPosition.xy += rotatedPosition;
	gl_Position = projectionMatrix * mvPosition;
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,dm=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Ue={alphahash_fragment:Nd,alphahash_pars_fragment:Dd,alphamap_fragment:Od,alphamap_pars_fragment:Ud,alphatest_fragment:Fd,alphatest_pars_fragment:Bd,aomap_fragment:kd,aomap_pars_fragment:Vd,batching_pars_vertex:Gd,batching_vertex:Hd,begin_vertex:Wd,beginnormal_vertex:Xd,bsdfs:qd,iridescence_fragment:Yd,bumpmap_pars_fragment:Zd,clipping_planes_fragment:Kd,clipping_planes_pars_fragment:Jd,clipping_planes_pars_vertex:$d,clipping_planes_vertex:jd,color_fragment:Qd,color_pars_fragment:ep,color_pars_vertex:tp,color_vertex:np,common:ip,cube_uv_reflection_fragment:sp,defaultnormal_vertex:rp,displacementmap_pars_vertex:ap,displacementmap_vertex:op,emissivemap_fragment:cp,emissivemap_pars_fragment:lp,colorspace_fragment:hp,colorspace_pars_fragment:up,envmap_fragment:fp,envmap_common_pars_fragment:dp,envmap_pars_fragment:pp,envmap_pars_vertex:mp,envmap_physical_pars_fragment:Ep,envmap_vertex:Mp,fog_vertex:gp,fog_pars_vertex:_p,fog_fragment:xp,fog_pars_fragment:yp,gradientmap_pars_fragment:vp,lightmap_pars_fragment:bp,lights_lambert_fragment:Sp,lights_lambert_pars_fragment:wp,lights_pars_begin:Tp,lights_toon_fragment:Ap,lights_toon_pars_fragment:Rp,lights_phong_fragment:Cp,lights_phong_pars_fragment:zp,lights_physical_fragment:Ip,lights_physical_pars_fragment:Pp,lights_fragment_begin:Lp,lights_fragment_maps:Np,lights_fragment_end:Dp,lightprobes_pars_fragment:Op,logdepthbuf_fragment:Up,logdepthbuf_pars_fragment:Fp,logdepthbuf_pars_vertex:Bp,logdepthbuf_vertex:kp,map_fragment:Vp,map_pars_fragment:Gp,map_particle_fragment:Hp,map_particle_pars_fragment:Wp,metalnessmap_fragment:Xp,metalnessmap_pars_fragment:qp,morphinstance_vertex:Yp,morphcolor_vertex:Zp,morphnormal_vertex:Kp,morphtarget_pars_vertex:Jp,morphtarget_vertex:$p,normal_fragment_begin:jp,normal_fragment_maps:Qp,normal_pars_fragment:e0,normal_pars_vertex:t0,normal_vertex:n0,normalmap_pars_fragment:i0,clearcoat_normal_fragment_begin:s0,clearcoat_normal_fragment_maps:r0,clearcoat_pars_fragment:a0,iridescence_pars_fragment:o0,opaque_fragment:c0,packing:l0,premultiplied_alpha_fragment:h0,project_vertex:u0,dithering_fragment:f0,dithering_pars_fragment:d0,roughnessmap_fragment:p0,roughnessmap_pars_fragment:m0,shadowmap_pars_fragment:M0,shadowmap_pars_vertex:g0,shadowmap_vertex:_0,shadowmask_pars_fragment:x0,skinbase_vertex:y0,skinning_pars_vertex:v0,skinning_vertex:b0,skinnormal_vertex:S0,specularmap_fragment:w0,specularmap_pars_fragment:T0,tonemapping_fragment:E0,tonemapping_pars_fragment:A0,transmission_fragment:R0,transmission_pars_fragment:C0,uv_pars_fragment:z0,uv_pars_vertex:I0,uv_vertex:P0,worldpos_vertex:L0,background_vert:N0,background_frag:D0,backgroundCube_vert:O0,backgroundCube_frag:U0,cube_vert:F0,cube_frag:B0,depth_vert:k0,depth_frag:V0,distance_vert:G0,distance_frag:H0,equirect_vert:W0,equirect_frag:X0,linedashed_vert:q0,linedashed_frag:Y0,meshbasic_vert:Z0,meshbasic_frag:K0,meshlambert_vert:J0,meshlambert_frag:$0,meshmatcap_vert:j0,meshmatcap_frag:Q0,meshnormal_vert:em,meshnormal_frag:tm,meshphong_vert:nm,meshphong_frag:im,meshphysical_vert:sm,meshphysical_frag:rm,meshtoon_vert:am,meshtoon_frag:om,points_vert:cm,points_frag:lm,shadow_vert:hm,shadow_frag:um,sprite_vert:fm,sprite_frag:dm},he={common:{diffuse:{value:new Ce(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new Ie},alphaMap:{value:null},alphaMapTransform:{value:new Ie},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new Ie}},envmap:{envMap:{value:null},envMapRotation:{value:new Ie},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98},dfgLUT:{value:null}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new Ie}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new Ie}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new Ie},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new Ie},normalScale:{value:new Oe(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new Ie},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new Ie}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new Ie}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new Ie}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new Ce(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},sunLights:{value:[],properties:{direction:{},color:{}}},sunLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},sunShadowMatrix:{value:[]},sunShadowCascade:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null},probesSH:{value:null},probesMin:{value:new O},probesMax:{value:new O},probesResolution:{value:new O}},points:{diffuse:{value:new Ce(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new Ie},alphaTest:{value:0},uvTransform:{value:new Ie}},sprite:{diffuse:{value:new Ce(16777215)},opacity:{value:1},center:{value:new Oe(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new Ie},alphaMap:{value:null},alphaMapTransform:{value:new Ie},alphaTest:{value:0}}},Bn={basic:{uniforms:Dt([he.common,he.specularmap,he.envmap,he.aomap,he.lightmap,he.fog]),vertexShader:Ue.meshbasic_vert,fragmentShader:Ue.meshbasic_frag},lambert:{uniforms:Dt([he.common,he.specularmap,he.envmap,he.aomap,he.lightmap,he.emissivemap,he.bumpmap,he.normalmap,he.displacementmap,he.fog,he.lights,{emissive:{value:new Ce(0)},envMapIntensity:{value:1}}]),vertexShader:Ue.meshlambert_vert,fragmentShader:Ue.meshlambert_frag},phong:{uniforms:Dt([he.common,he.specularmap,he.envmap,he.aomap,he.lightmap,he.emissivemap,he.bumpmap,he.normalmap,he.displacementmap,he.fog,he.lights,{emissive:{value:new Ce(0)},specular:{value:new Ce(1118481)},shininess:{value:30},envMapIntensity:{value:1}}]),vertexShader:Ue.meshphong_vert,fragmentShader:Ue.meshphong_frag},standard:{uniforms:Dt([he.common,he.envmap,he.aomap,he.lightmap,he.emissivemap,he.bumpmap,he.normalmap,he.displacementmap,he.roughnessmap,he.metalnessmap,he.fog,he.lights,{emissive:{value:new Ce(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Ue.meshphysical_vert,fragmentShader:Ue.meshphysical_frag},toon:{uniforms:Dt([he.common,he.aomap,he.lightmap,he.emissivemap,he.bumpmap,he.normalmap,he.displacementmap,he.gradientmap,he.fog,he.lights,{emissive:{value:new Ce(0)}}]),vertexShader:Ue.meshtoon_vert,fragmentShader:Ue.meshtoon_frag},matcap:{uniforms:Dt([he.common,he.bumpmap,he.normalmap,he.displacementmap,he.fog,{matcap:{value:null}}]),vertexShader:Ue.meshmatcap_vert,fragmentShader:Ue.meshmatcap_frag},points:{uniforms:Dt([he.points,he.fog]),vertexShader:Ue.points_vert,fragmentShader:Ue.points_frag},dashed:{uniforms:Dt([he.common,he.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Ue.linedashed_vert,fragmentShader:Ue.linedashed_frag},depth:{uniforms:Dt([he.common,he.displacementmap]),vertexShader:Ue.depth_vert,fragmentShader:Ue.depth_frag},normal:{uniforms:Dt([he.common,he.bumpmap,he.normalmap,he.displacementmap,{opacity:{value:1}}]),vertexShader:Ue.meshnormal_vert,fragmentShader:Ue.meshnormal_frag},sprite:{uniforms:Dt([he.sprite,he.fog]),vertexShader:Ue.sprite_vert,fragmentShader:Ue.sprite_frag},background:{uniforms:{uvTransform:{value:new Ie},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Ue.background_vert,fragmentShader:Ue.background_frag},backgroundCube:{uniforms:{envMap:{value:null},backgroundBlurriness:{value:0},backgroundIntensity:{value:1},backgroundRotation:{value:new Ie}},vertexShader:Ue.backgroundCube_vert,fragmentShader:Ue.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Ue.cube_vert,fragmentShader:Ue.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Ue.equirect_vert,fragmentShader:Ue.equirect_frag},distance:{uniforms:Dt([he.common,he.displacementmap,{referencePosition:{value:new O},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Ue.distance_vert,fragmentShader:Ue.distance_frag},shadow:{uniforms:Dt([he.lights,he.fog,{color:{value:new Ce(0)},opacity:{value:1}}]),vertexShader:Ue.shadow_vert,fragmentShader:Ue.shadow_frag}};Bn.physical={uniforms:Dt([Bn.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new Ie},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new Ie},clearcoatNormalScale:{value:new Oe(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new Ie},dispersion:{value:0},retroreflectivity:{value:0},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new Ie},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new Ie},sheen:{value:0},sheenColor:{value:new Ce(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new Ie},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new Ie},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new Ie},transmissionSamplerSize:{value:new Oe},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new Ie},attenuationDistance:{value:0},attenuationColor:{value:new Ce(0)},specularColor:{value:new Ce(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new Ie},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new Ie},anisotropyVector:{value:new Oe},anisotropyMap:{value:null},anisotropyMapTransform:{value:new Ie}}]),vertexShader:Ue.meshphysical_vert,fragmentShader:Ue.meshphysical_frag};var To={r:0,b:0,g:0},pm=new Ne,Qu=new Ie;Qu.set(-1,0,0,0,1,0,0,0,1);function mm(i,e,t,n,s,r){let a=new Ce(0),o=s===!0?0:1,c,l,h=null,f=0,u=null;function d(T){let R=T.isScene===!0?T.background:null;if(R&&R.isTexture){let v=T.backgroundBlurriness>0;R=e.get(R,v)}return R}function g(T){let R=!1,v=d(T);v===null?m(a,o):v&&v.isColor&&(m(v,1),R=!0);let b=i.xr.getEnvironmentBlendMode();b==="additive"?t.buffers.color.setClear(0,0,0,1,r):b==="alpha-blend"&&t.buffers.color.setClear(0,0,0,0,r),(i.autoClear||R)&&(t.buffers.depth.setTest(!0),t.buffers.depth.setMask(!0),t.buffers.color.setMask(!0),i.clear(i.autoClearColor,i.autoClearDepth,i.autoClearStencil))}function y(T,R){let v=d(R);v&&(v.isCubeTexture||v.mapping===xr)?(l===void 0&&(l=new Ct(new bs(1,1,1),new tn({name:"BackgroundCubeMaterial",uniforms:ki(Bn.backgroundCube.uniforms),vertexShader:Bn.backgroundCube.vertexShader,fragmentShader:Bn.backgroundCube.fragmentShader,side:Gt,depthTest:!1,depthWrite:!1,fog:!1,allowOverride:!1})),l.geometry.deleteAttribute("normal"),l.geometry.deleteAttribute("uv"),l.onBeforeRender=function(b,S,A){this.matrixWorld.copyPosition(A.matrixWorld)},Object.defineProperty(l.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),n.update(l)),l.material.uniforms.envMap.value=v,l.material.uniforms.backgroundBlurriness.value=R.backgroundBlurriness,l.material.uniforms.backgroundIntensity.value=R.backgroundIntensity,l.material.uniforms.backgroundRotation.value.setFromMatrix4(pm.makeRotationFromEuler(R.backgroundRotation)).transpose(),v.isCubeTexture&&v.isRenderTargetTexture===!1&&l.material.uniforms.backgroundRotation.value.premultiply(Qu),l.material.toneMapped=Fe.getTransfer(v.colorSpace)!==$e,(h!==v||f!==v.version||u!==i.toneMapping)&&(l.material.needsUpdate=!0,h=v,f=v.version,u=i.toneMapping),l.layers.enableAll(),T.unshift(l,l.geometry,l.material,0,0,null)):v&&v.isTexture&&(c===void 0&&(c=new Ct(new lr(2,2),new tn({name:"BackgroundMaterial",uniforms:ki(Bn.background.uniforms),vertexShader:Bn.background.vertexShader,fragmentShader:Bn.background.fragmentShader,side:On,depthTest:!1,depthWrite:!1,fog:!1,allowOverride:!1})),c.geometry.deleteAttribute("normal"),Object.defineProperty(c.material,"map",{get:function(){return this.uniforms.t2D.value}}),n.update(c)),c.material.uniforms.t2D.value=v,c.material.uniforms.backgroundIntensity.value=R.backgroundIntensity,c.material.toneMapped=Fe.getTransfer(v.colorSpace)!==$e,v.matrixAutoUpdate===!0&&v.updateMatrix(),c.material.uniforms.uvTransform.value.copy(v.matrix),(h!==v||f!==v.version||u!==i.toneMapping)&&(c.material.needsUpdate=!0,h=v,f=v.version,u=i.toneMapping),c.layers.enableAll(),T.unshift(c,c.geometry,c.material,0,0,null))}function m(T,R){T.getRGB(To,jc(i)),t.buffers.color.setClear(To.r,To.g,To.b,R,r)}function p(){l!==void 0&&(l.geometry.dispose(),l.material.dispose(),l=void 0),c!==void 0&&(c.geometry.dispose(),c.material.dispose(),c=void 0)}return{getClearColor:function(){return a},setClearColor:function(T,R=1){a.set(T),o=R,m(a,o)},getClearAlpha:function(){return o},setClearAlpha:function(T){o=T,m(a,o)},render:g,addToRenderList:y,dispose:p}}function Mm(i,e){let t=i.getParameter(i.MAX_VERTEX_ATTRIBS),n={},s=u(null),r=s,a=!1;function o(N,k,H,L,V){let K=!1,Z=f(N,L,H,k);r!==Z&&(r=Z,l(r.object)),K=d(N,L,H,V),K&&g(N,L,H,V),V!==null&&e.update(V,i.ELEMENT_ARRAY_BUFFER),(K||a)&&(a=!1,v(N,k,H,L),V!==null&&i.bindBuffer(i.ELEMENT_ARRAY_BUFFER,e.get(V).buffer))}function c(){return i.createVertexArray()}function l(N){return i.bindVertexArray(N)}function h(N){return i.deleteVertexArray(N)}function f(N,k,H,L){let V=L.wireframe===!0,K=n[k.id];K===void 0&&(K={},n[k.id]=K);let Z=N.isInstancedMesh===!0?N.id:0,ne=K[Z];ne===void 0&&(ne={},K[Z]=ne);let X=ne[H.id];X===void 0&&(X={},ne[H.id]=X);let Q=X[V];return Q===void 0&&(Q=u(c()),X[V]=Q),Q}function u(N){let k=[],H=[],L=[];for(let V=0;V<t;V++)k[V]=0,H[V]=0,L[V]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:k,enabledAttributes:H,attributeDivisors:L,object:N,attributes:{},index:null}}function d(N,k,H,L){let V=r.attributes,K=k.attributes,Z=0,ne=H.getAttributes();for(let X in ne)if(ne[X].location>=0){let te=V[X],Ae=K[X];if(Ae===void 0&&(X==="instanceMatrix"&&N.instanceMatrix&&(Ae=N.instanceMatrix),X==="instanceColor"&&N.instanceColor&&(Ae=N.instanceColor)),te===void 0||te.attribute!==Ae||Ae&&te.data!==Ae.data)return!0;Z++}return r.attributesNum!==Z||r.index!==L}function g(N,k,H,L){let V={},K=k.attributes,Z=0,ne=H.getAttributes();for(let X in ne)if(ne[X].location>=0){let te=K[X];te===void 0&&(X==="instanceMatrix"&&N.instanceMatrix&&(te=N.instanceMatrix),X==="instanceColor"&&N.instanceColor&&(te=N.instanceColor));let Ae={};Ae.attribute=te,te&&te.data&&(Ae.data=te.data),V[X]=Ae,Z++}r.attributes=V,r.attributesNum=Z,r.index=L}function y(){let N=r.newAttributes;for(let k=0,H=N.length;k<H;k++)N[k]=0}function m(N){p(N,0)}function p(N,k){let H=r.newAttributes,L=r.enabledAttributes,V=r.attributeDivisors;H[N]=1,L[N]===0&&(i.enableVertexAttribArray(N),L[N]=1),V[N]!==k&&(i.vertexAttribDivisor(N,k),V[N]=k)}function T(){let N=r.newAttributes,k=r.enabledAttributes;for(let H=0,L=k.length;H<L;H++)k[H]!==N[H]&&(i.disableVertexAttribArray(H),k[H]=0)}function R(N,k,H,L,V,K,Z){Z===!0?i.vertexAttribIPointer(N,k,H,V,K):i.vertexAttribPointer(N,k,H,L,V,K)}function v(N,k,H,L){y();let V=L.attributes,K=H.getAttributes(),Z=k.defaultAttributeValues;for(let ne in K){let X=K[ne];if(X.location>=0){let Q=V[ne];if(Q===void 0&&(ne==="instanceMatrix"&&N.instanceMatrix&&(Q=N.instanceMatrix),ne==="instanceColor"&&N.instanceColor&&(Q=N.instanceColor)),Q!==void 0){let te=Q.normalized,Ae=Q.itemSize,Te=e.get(Q);if(Te===void 0)continue;let st=Te.buffer,Xe=Te.type,Ze=Te.bytesPerElement,q=Xe===i.INT||Xe===i.UNSIGNED_INT||Q.gpuType===Ba;if(Q.isInterleavedBufferAttribute){let j=Q.data,ge=j.stride,Pe=Q.offset;if(j.isInstancedInterleavedBuffer){for(let me=0;me<X.locationSize;me++)p(X.location+me,j.meshPerAttribute);N.isInstancedMesh!==!0&&L._maxInstanceCount===void 0&&(L._maxInstanceCount=j.meshPerAttribute*j.count)}else for(let me=0;me<X.locationSize;me++)m(X.location+me);i.bindBuffer(i.ARRAY_BUFFER,st);for(let me=0;me<X.locationSize;me++)R(X.location+me,Ae/X.locationSize,Xe,te,ge*Ze,(Pe+Ae/X.locationSize*me)*Ze,q)}else{if(Q.isInstancedBufferAttribute){for(let j=0;j<X.locationSize;j++)p(X.location+j,Q.meshPerAttribute);N.isInstancedMesh!==!0&&L._maxInstanceCount===void 0&&(L._maxInstanceCount=Q.meshPerAttribute*Q.count)}else for(let j=0;j<X.locationSize;j++)m(X.location+j);i.bindBuffer(i.ARRAY_BUFFER,st);for(let j=0;j<X.locationSize;j++)R(X.location+j,Ae/X.locationSize,Xe,te,Ae*Ze,Ae/X.locationSize*j*Ze,q)}}else if(Z!==void 0){let te=Z[ne];if(te!==void 0)switch(te.length){case 2:i.vertexAttrib2fv(X.location,te);break;case 3:i.vertexAttrib3fv(X.location,te);break;case 4:i.vertexAttrib4fv(X.location,te);break;default:i.vertexAttrib1fv(X.location,te)}}}}T()}function b(){E();for(let N in n){let k=n[N];for(let H in k){let L=k[H];for(let V in L){let K=L[V];for(let Z in K)h(K[Z].object),delete K[Z];delete L[V]}}delete n[N]}}function S(N){if(n[N.id]===void 0)return;let k=n[N.id];for(let H in k){let L=k[H];for(let V in L){let K=L[V];for(let Z in K)h(K[Z].object),delete K[Z];delete L[V]}}delete n[N.id]}function A(N){for(let k in n){let H=n[k];for(let L in H){let V=H[L];if(V[N.id]===void 0)continue;let K=V[N.id];for(let Z in K)h(K[Z].object),delete K[Z];delete V[N.id]}}}function _(N){for(let k in n){let H=n[k],L=N.isInstancedMesh===!0?N.id:0,V=H[L];if(V!==void 0){for(let K in V){let Z=V[K];for(let ne in Z)h(Z[ne].object),delete Z[ne];delete V[K]}delete H[L],Object.keys(H).length===0&&delete n[k]}}}function E(){P(),a=!0,r!==s&&(r=s,l(r.object))}function P(){s.geometry=null,s.program=null,s.wireframe=!1}return{setup:o,reset:E,resetDefaultState:P,dispose:b,releaseStatesOfGeometry:S,releaseStatesOfObject:_,releaseStatesOfProgram:A,initAttributes:y,enableAttribute:m,disableUnusedAttributes:T}}function gm(i,e,t){let n;function s(c){n=c}function r(c,l){i.drawArrays(n,c,l),t.update(l,n,1)}function a(c,l,h){h!==0&&(i.drawArraysInstanced(n,c,l,h),t.update(l,n,h))}function o(c,l,h){if(h===0)return;e.get("WEBGL_multi_draw").multiDrawArraysWEBGL(n,c,0,l,0,h);let u=0;for(let d=0;d<h;d++)u+=l[d];t.update(u,n,1)}this.setMode=s,this.render=r,this.renderInstances=a,this.renderMultiDraw=o}function _m(i,e,t,n){let s;function r(){if(s!==void 0)return s;if(e.has("EXT_texture_filter_anisotropic")===!0){let A=e.get("EXT_texture_filter_anisotropic");s=i.getParameter(A.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else s=0;return s}function a(A){return!(A!==sn&&n.convert(A)!==i.getParameter(i.IMPLEMENTATION_COLOR_READ_FORMAT))}function o(A){let _=A===wn&&(e.has("EXT_color_buffer_half_float")||e.has("EXT_color_buffer_float"));return!(A!==Zt&&A!==nn&&!_&&n.convert(A)!==i.getParameter(i.IMPLEMENTATION_COLOR_READ_TYPE))}function c(A){if(A==="highp"){if(i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.HIGH_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.HIGH_FLOAT).precision>0)return"highp";A="mediump"}return A==="mediump"&&i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.MEDIUM_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}let l=t.precision!==void 0?t.precision:"highp",h=c(l);h!==l&&(be("WebGLRenderer:",l,"not supported, using",h,"instead."),l=h);let f=t.logarithmicDepthBuffer===!0,u=t.reversedDepthBuffer===!0&&e.has("EXT_clip_control");t.reversedDepthBuffer===!0&&u===!1&&be("WebGLRenderer: Unable to use reversed depth buffer due to missing EXT_clip_control extension. Fallback to default depth buffer.");let d=i.getParameter(i.MAX_TEXTURE_IMAGE_UNITS),g=i.getParameter(i.MAX_VERTEX_TEXTURE_IMAGE_UNITS),y=i.getParameter(i.MAX_TEXTURE_SIZE),m=i.getParameter(i.MAX_CUBE_MAP_TEXTURE_SIZE),p=i.getParameter(i.MAX_VERTEX_ATTRIBS),T=i.getParameter(i.MAX_VERTEX_UNIFORM_VECTORS),R=i.getParameter(i.MAX_VARYING_VECTORS),v=i.getParameter(i.MAX_FRAGMENT_UNIFORM_VECTORS),b=i.getParameter(i.MAX_SAMPLES),S=i.getParameter(i.SAMPLES);return{isWebGL2:!0,getMaxAnisotropy:r,getMaxPrecision:c,textureFormatReadable:a,textureTypeReadable:o,precision:l,logarithmicDepthBuffer:f,reversedDepthBuffer:u,maxTextures:d,maxVertexTextures:g,maxTextureSize:y,maxCubemapSize:m,maxAttributes:p,maxVertexUniforms:T,maxVaryings:R,maxFragmentUniforms:v,maxSamples:b,samples:S}}function xm(i){let e=this,t=null,n=0,s=!1,r=!1,a=new Mn,o=new Ie,c={value:null,needsUpdate:!1};this.uniform=c,this.numPlanes=0,this.numIntersection=0,this.init=function(f,u){let d=f.length!==0||u||n!==0||s;return s=u,n=f.length,d},this.beginShadows=function(){r=!0,h(null)},this.endShadows=function(){r=!1},this.setGlobalState=function(f,u){t=h(f,u,0)},this.setState=function(f,u,d){let g=f.clippingPlanes,y=f.clipIntersection,m=f.clipShadows,p=i.get(f);if(!s||g===null||g.length===0||r&&!m)r?h(null):l();else{let T=r?0:n,R=T*4,v=p.clippingState||null;c.value=v,v=h(g,u,R,d);for(let b=0;b!==R;++b)v[b]=t[b];p.clippingState=v,this.numIntersection=y?this.numPlanes:0,this.numPlanes+=T}};function l(){c.value!==t&&(c.value=t,c.needsUpdate=n>0),e.numPlanes=n,e.numIntersection=0}function h(f,u,d,g){let y=f!==null?f.length:0,m=null;if(y!==0){if(m=c.value,g!==!0||m===null){let p=d+y*4,T=u.matrixWorldInverse;o.getNormalMatrix(T),(m===null||m.length<p)&&(m=new Float32Array(p));for(let R=0,v=d;R!==y;++R,v+=4)a.copy(f[R]).applyMatrix4(T,o),a.normal.toArray(m,v),m[v+3]=a.constant}c.value=m,c.needsUpdate=!0}return e.numPlanes=y,e.numIntersection=0,m}}var Ps=4,ym=6,vm=20,bm=256,Rr=new Mi,Iu=new Ce,nl=null,il=0,sl=0,rl=!1,Sm=new O,Vi=new O,Ao=class{constructor(e){this._renderer=e,this._pingPongRenderTarget=null,this._lodMax=0,this._cubeSize=0,this._sizeLods=[],this._lodMeshes=[],this._backgroundBox=null,this._cubemapMaterial=null,this._equirectMaterial=null,this._blurMaterial=null,this._ggxMaterial=null}fromScene(e,t=0,n=.1,s=100,r={}){let{size:a=256,position:o=Sm}=r;nl=this._renderer.getRenderTarget(),il=this._renderer.getActiveCubeFace(),sl=this._renderer.getActiveMipmapLevel(),rl=this._renderer.xr.enabled,this._renderer.xr.enabled=!1,this._setSize(a);let c=this._allocateTargets();return c.depthBuffer=!0,this._sceneToCubeUV(e,n,s,c,o),t>0&&this._blur(c,0,0,t),this._applyPMREM(c),this._cleanup(c),c}fromEquirectangular(e,t=null){return this._fromTexture(e,t)}fromCubemap(e,t=null){return this._fromTexture(e,t)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=Nu(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=Lu(),this._compileMaterial(this._equirectMaterial))}dispose(){this._dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose(),this._backgroundBox!==null&&(this._backgroundBox.geometry.dispose(),this._backgroundBox.material.dispose())}_setSize(e){this._lodMax=Math.floor(Math.log2(e)),this._cubeSize=Math.pow(2,this._lodMax)}_dispose(){this._blurMaterial!==null&&this._blurMaterial.dispose(),this._ggxMaterial!==null&&this._ggxMaterial.dispose(),this._pingPongRenderTarget!==null&&this._pingPongRenderTarget.dispose();for(let e=0;e<this._lodMeshes.length;e++)this._lodMeshes[e].geometry.dispose()}_cleanup(e){this._renderer.setRenderTarget(nl,il,sl),this._renderer.xr.enabled=rl,e.scissorTest=!1,Is(e,0,0,e.width,e.height)}_fromTexture(e,t){e.mapping===gi||e.mapping===Fi?this._setSize(e.image.length===0?16:e.image[0].width||e.image[0].image.width):this._setSize(e.image.width/4),nl=this._renderer.getRenderTarget(),il=this._renderer.getActiveCubeFace(),sl=this._renderer.getActiveMipmapLevel(),rl=this._renderer.xr.enabled,this._renderer.xr.enabled=!1;let n=t||this._allocateTargets();return this._textureToCubeUV(e,n),this._applyPMREM(n),this._cleanup(n),n}_allocateTargets(){let e=3*Math.max(this._cubeSize,112),t=4*this._cubeSize,n={magFilter:pt,minFilter:pt,generateMipmaps:!1,type:wn,format:sn,colorSpace:kt,depthBuffer:!1},s=Pu(e,t,n);if(this._pingPongRenderTarget===null||this._pingPongRenderTarget.width!==e||this._pingPongRenderTarget.height!==t){this._pingPongRenderTarget!==null&&this._dispose(),this._pingPongRenderTarget=Pu(e,t,n);let{_lodMax:r}=this;({lodMeshes:this._lodMeshes,sizeLods:this._sizeLods}=wm(r)),this._blurMaterial=Em(r,e,t),this._ggxMaterial=Tm(r,e,t)}return s}_compileMaterial(e){let t=new Ct(new Nt,e);this._renderer.compile(t,Rr)}_sceneToCubeUV(e,t,n,s,r){let c=new xt(90,1,t,n),l=[1,-1,1,1,1,1],h=[1,1,1,-1,-1,-1],f=this._renderer,u=f.autoClear,d=f.toneMapping;f.getClearColor(Iu),f.toneMapping=vn,f.autoClear=!1,f.state.buffers.depth.getReversed()&&(f.setRenderTarget(s),f.clearDepth(),f.setRenderTarget(null)),this._backgroundBox===null&&(this._backgroundBox=new Ct(new bs,new yn({name:"PMREM.Background",side:Gt,depthWrite:!1,depthTest:!1})));let y=this._backgroundBox,m=y.material,p=!1,T=e.background;T?T.isColor&&(m.color.copy(T),e.background=null,p=!0):(m.color.copy(Iu),p=!0);for(let R=0;R<6;R++){let v=R%3;v===0?(c.up.set(0,l[R],0),c.position.set(r.x,r.y,r.z),c.lookAt(r.x+h[R],r.y,r.z)):v===1?(c.up.set(0,0,l[R]),c.position.set(r.x,r.y,r.z),c.lookAt(r.x,r.y+h[R],r.z)):(c.up.set(0,l[R],0),c.position.set(r.x,r.y,r.z),c.lookAt(r.x,r.y,r.z+h[R]));let b=this._cubeSize;Is(s,v*b,R>2?b:0,b,b),f.setRenderTarget(s),p&&f.render(y,c),f.render(e,c)}f.toneMapping=d,f.autoClear=u,e.background=T}_textureToCubeUV(e,t){let n=this._renderer,s=e.mapping===gi||e.mapping===Fi;s?(this._cubemapMaterial===null&&(this._cubemapMaterial=Nu()),this._cubemapMaterial.uniforms.flipEnvMap.value=e.isRenderTargetTexture===!1?-1:1):this._equirectMaterial===null&&(this._equirectMaterial=Lu());let r=s?this._cubemapMaterial:this._equirectMaterial,a=this._lodMeshes[0];a.material=r;let o=r.uniforms;o.envMap.value=e;let c=this._cubeSize;Is(t,0,0,3*c,2*c),n.setRenderTarget(t),n.render(a,Rr)}_applyPMREM(e){let t=this._renderer,n=t.autoClear;t.autoClear=!1;let s=this._lodMeshes.length;for(let r=1;r<s;r++)this._applyGGXFilter(e,r-1,r);t.autoClear=n}_applyGGXFilter(e,t,n){let s=this._renderer,r=this._pingPongRenderTarget,a=this._ggxMaterial,o=this._lodMeshes[n];o.material=a;let c=a.uniforms,l=n/(this._lodMeshes.length-1),h=t/(this._lodMeshes.length-1),f=Math.sqrt(l*l-h*h),u=l*1.25,d=f*u,{_lodMax:g}=this,y=this._sizeLods[n],m=3*y*(n>g-Ps?n-g+Ps:0),p=4*(this._cubeSize-y);c.envMap.value=e.texture,c.roughness.value=d,c.mipInt.value=g-t,Is(r,m,p,3*y,2*y),s.setRenderTarget(r),s.render(o,Rr),c.envMap.value=r.texture,c.roughness.value=0,c.mipInt.value=g-n,Is(e,m,p,3*y,2*y),s.setRenderTarget(e),s.render(o,Rr)}_blur(e,t,n,s){let r=this._pingPongRenderTarget,a=Math.min(s,Math.PI)/Math.SQRT2;this._blurPass(e,r,t,n,a),this._blurPass(r,e,n,n,a)}_blurPass(e,t,n,s,r){let a=this._renderer,o=this._blurMaterial,c=this._lodMeshes[s];c.material=o;let l=o.uniforms;l.envMap.value=e.texture,l.sigma.value=r,l.mipInt.value=this._lodMax-n;let h=this._sizeLods[s],f=3*h*(s>this._lodMax-Ps?s-this._lodMax+Ps:0),u=4*(this._cubeSize-h);Is(t,f,u,3*h,2*h),a.setRenderTarget(t),a.render(c,Rr)}};function wm(i){let e=[],t=[],n=i,s=i-Ps+1+ym;for(let r=0;r<s;r++){let a=Math.pow(2,n);e.push(a);let o=1/(a-2),c=-o,l=1+o,h=[c,c,l,c,l,l,c,c,l,l,c,l],f=6,u=6,d=3,g=new Float32Array(d*u*f),y=new Float32Array(d*u*f);for(let p=0;p<f;p++){let T=p%3*2/3-1,R=p>2?0:-1,v=[T,R,0,T+2/3,R,0,T+2/3,R+1,0,T,R,0,T+2/3,R+1,0,T,R+1,0];g.set(v,d*u*p);for(let b=0;b<u;b++){let S=h[b*2]*2-1,A=h[b*2+1]*2-1;p===0?Vi.set(1,A,S):p===1?Vi.set(-S,1,-A):p===2?Vi.set(-S,A,1):p===3?Vi.set(-1,A,-S):p===4?Vi.set(-S,-1,A):Vi.set(S,A,-1),Vi.toArray(y,(p*u+b)*d)}}let m=new Nt;m.setAttribute("position",new bt(g,d)),m.setAttribute("outputDirection",new bt(y,d)),t.push(new Ct(m,null)),n>Ps&&n--}return{lodMeshes:t,sizeLods:e}}function Pu(i,e,t){let n=new Wt(i,e,t);return n.texture.mapping=xr,n.texture.name="PMREM.cubeUv",n.scissorTest=!0,n}function Is(i,e,t,n,s){i.viewport.set(e,t,n,s),i.scissor.set(e,t,n,s)}function Tm(i,e,t){return new tn({name:"PMREMGGXConvolution",defines:{GGX_SAMPLES:bm,CUBEUV_TEXEL_WIDTH:1/e,CUBEUV_TEXEL_HEIGHT:1/t,CUBEUV_MAX_MIP:`${i}.0`},uniforms:{envMap:{value:null},roughness:{value:0},mipInt:{value:0}},vertexShader:zo(),fragmentShader:`

			precision highp float;
			precision highp int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform float roughness;
			uniform float mipInt;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			#define PI 3.14159265359

			// Van der Corput radical inverse
			float radicalInverse_VdC(uint bits) {
				bits = (bits << 16u) | (bits >> 16u);
				bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
				bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
				bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
				bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
				return float(bits) * 2.3283064365386963e-10; // / 0x100000000
			}

			// Hammersley sequence
			vec2 hammersley(uint i, uint N) {
				return vec2(float(i) / float(N), radicalInverse_VdC(i));
			}

			// GGX VNDF importance sampling (Eric Heitz 2018)
			// "Sampling the GGX Distribution of Visible Normals"
			// https://jcgt.org/published/0007/04/01/
			vec3 importanceSampleGGX_VNDF(vec2 Xi, vec3 V, float roughness) {
				float alpha = roughness * roughness;

				// Section 4.1: Orthonormal basis
				vec3 T1 = vec3(1.0, 0.0, 0.0);
				vec3 T2 = cross(V, T1);

				// Section 4.2: Parameterization of projected area
				float r = sqrt(Xi.x);
				float phi = 2.0 * PI * Xi.y;
				float t1 = r * cos(phi);
				float t2 = r * sin(phi);
				float s = 0.5 * (1.0 + V.z);
				t2 = (1.0 - s) * sqrt(1.0 - t1 * t1) + s * t2;

				// Section 4.3: Reprojection onto hemisphere
				vec3 Nh = t1 * T1 + t2 * T2 + sqrt(max(0.0, 1.0 - t1 * t1 - t2 * t2)) * V;

				// Section 3.4: Transform back to ellipsoid configuration
				return normalize(vec3(alpha * Nh.x, alpha * Nh.y, max(0.0, Nh.z)));
			}

			void main() {
				vec3 N = normalize(vOutputDirection);
				vec3 V = N; // Assume view direction equals normal for pre-filtering

				vec3 prefilteredColor = vec3(0.0);
				float totalWeight = 0.0;

				// For very low roughness, just sample the environment directly
				if (roughness < 0.001) {
					gl_FragColor = vec4(bilinearCubeUV(envMap, N, mipInt), 1.0);
					return;
				}

				// Tangent space basis for VNDF sampling
				vec3 up = abs(N.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
				vec3 tangent = normalize(cross(up, N));
				vec3 bitangent = cross(N, tangent);

				for(uint i = 0u; i < uint(GGX_SAMPLES); i++) {
					vec2 Xi = hammersley(i, uint(GGX_SAMPLES));

					// For PMREM, V = N, so in tangent space V is always (0, 0, 1)
					vec3 H_tangent = importanceSampleGGX_VNDF(Xi, vec3(0.0, 0.0, 1.0), roughness);

					// Transform H back to world space
					vec3 H = normalize(tangent * H_tangent.x + bitangent * H_tangent.y + N * H_tangent.z);
					vec3 L = normalize(2.0 * dot(V, H) * H - V);

					float NdotL = max(dot(N, L), 0.0);

					if(NdotL > 0.0) {
						// Sample environment at fixed mip level
						// VNDF importance sampling handles the distribution filtering
						vec3 sampleColor = bilinearCubeUV(envMap, L, mipInt);

						// Weight by NdotL for the split-sum approximation
						// VNDF PDF naturally accounts for the visible microfacet distribution
						prefilteredColor += sampleColor * NdotL;
						totalWeight += NdotL;
					}
				}

				if (totalWeight > 0.0) {
					prefilteredColor = prefilteredColor / totalWeight;
				}

				gl_FragColor = vec4(prefilteredColor, 1.0);
			}
		`,blending:Un,depthTest:!1,depthWrite:!1})}function Em(i,e,t){return new tn({name:"SphericalGaussianBlur",defines:{SAMPLES:vm,CUBEUV_TEXEL_WIDTH:1/e,CUBEUV_TEXEL_HEIGHT:1/t,CUBEUV_MAX_MIP:`${i}.0`},uniforms:{envMap:{value:null},sigma:{value:0},mipInt:{value:0}},vertexShader:zo(),fragmentShader:`

			precision highp float;
			precision highp int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform float sigma;
			uniform float mipInt;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			#define PI 3.14159265359
			#define GOLDEN_ANGLE 2.39996322973

			void main() {

				if ( sigma == 0.0 ) {

					gl_FragColor = vec4( bilinearCubeUV( envMap, vOutputDirection, mipInt ), 1.0 );
					return;

				}

				vec3 outputDirection = normalize( vOutputDirection );

				vec3 up = abs( outputDirection.z ) < 0.999 ? vec3( 0.0, 0.0, 1.0 ) : vec3( 1.0, 0.0, 0.0 );
				vec3 tangent = normalize( cross( up, outputDirection ) );
				vec3 bitangent = cross( outputDirection, tangent );

				// Truncate the kernel at three standard deviations or at the antipode.
				float thetaMax = min( 3.0 * sigma, PI );
				float truncation = 1.0 - exp( - 0.5 * thetaMax * thetaMax / ( sigma * sigma ) );

				vec3 accumColor = vec3( 0.0 );
				float accumWeight = 0.0;

				for ( int i = 0; i < SAMPLES; i ++ ) {

					// Stratified inverse-CDF sampling of the Gaussian, placed on a golden-angle spiral.
					float stratum = ( float( i ) + 0.5 ) / float( SAMPLES );
					float theta = sigma * sqrt( - 2.0 * log( 1.0 - stratum * truncation ) );
					float phi = float( i ) * GOLDEN_ANGLE;

					vec3 offset = cos( phi ) * tangent + sin( phi ) * bitangent;
					vec3 sampleDirection = cos( theta ) * outputDirection + sin( theta ) * offset;

					// Correct the planar sample density to solid angle.
					float weight = sin( theta ) / theta;

					accumColor += weight * bilinearCubeUV( envMap, sampleDirection, mipInt );
					accumWeight += weight;

				}

				gl_FragColor = vec4( accumColor / accumWeight, 1.0 );

			}
		`,blending:Un,depthTest:!1,depthWrite:!1})}function Lu(){return new tn({name:"EquirectangularToCubeUV",uniforms:{envMap:{value:null}},vertexShader:zo(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;

			#include <common>

			void main() {

				vec3 outputDirection = normalize( vOutputDirection );
				vec2 uv = equirectUv( outputDirection );

				gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );

			}
		`,blending:Un,depthTest:!1,depthWrite:!1})}function Nu(){return new tn({name:"CubemapToCubeUV",uniforms:{envMap:{value:null},flipEnvMap:{value:-1}},vertexShader:zo(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		`,blending:Un,depthTest:!1,depthWrite:!1})}function zo(){return`

		precision mediump float;
		precision mediump int;

		attribute vec3 outputDirection;

		varying vec3 vOutputDirection;

		void main() {

			vOutputDirection = outputDirection;
			gl_Position = vec4( position, 1.0 );

		}
	`}var Ro=class extends Wt{constructor(e=1,t={}){super(e,e,t),this.isWebGLCubeRenderTarget=!0;let n={width:e,height:e,depth:1},s=[n,n,n,n,n,n];this.texture=new or(s),this._setTextureOptions(t),this.texture.isRenderTargetTexture=!0}fromEquirectangularTexture(e,t){this.texture.type=t.type,this.texture.colorSpace=t.colorSpace,this.texture.generateMipmaps=t.generateMipmaps,this.texture.minFilter=t.minFilter,this.texture.magFilter=t.magFilter;let n={uniforms:{tEquirect:{value:null}},vertexShader:`

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			`,fragmentShader:`

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			`},s=new bs(5,5,5),r=new tn({name:"CubemapFromEquirect",uniforms:ki(n.uniforms),vertexShader:n.vertexShader,fragmentShader:n.fragmentShader,side:Gt,blending:Un});r.uniforms.tEquirect.value=t;let a=new Ct(s,r),o=t.minFilter;return t.minFilter===bn&&(t.minFilter=pt),new La(1,10,this).update(e,a),t.minFilter=o,a.geometry.dispose(),a.material.dispose(),this}clear(e,t=!0,n=!0,s=!0){let r=e.getRenderTarget();for(let a=0;a<6;a++)e.setRenderTarget(this,a),e.clear(t,n,s);e.setRenderTarget(r)}};function Am(i){let e=new WeakMap,t=new WeakMap,n=null;function s(u,d=!1){return u==null?null:d?a(u):r(u)}function r(u){if(u&&u.isTexture){let d=u.mapping;if(d===Oa||d===Ua)if(e.has(u)){let g=e.get(u).texture;return o(g,u.mapping)}else{let g=u.image;if(g&&g.height>0){let y=new Ro(g.height);return y.fromEquirectangularTexture(i,u),e.set(u,y),u.addEventListener("dispose",l),o(y.texture,u.mapping)}else return null}}return u}function a(u){if(u&&u.isTexture){let d=u.mapping,g=d===Oa||d===Ua,y=d===gi||d===Fi;if(g||y){let m=t.get(u),p=m!==void 0?m.texture.pmremVersion:0;if(u.isRenderTargetTexture&&u.pmremVersion!==p)return n===null&&(n=new Ao(i)),m=g?n.fromEquirectangular(u,m):n.fromCubemap(u,m),m.texture.pmremVersion=u.pmremVersion,t.set(u,m),m.texture;if(m!==void 0)return m.texture;{let T=u.image;return g&&T&&T.height>0||y&&T&&c(T)?(n===null&&(n=new Ao(i)),m=g?n.fromEquirectangular(u):n.fromCubemap(u),m.texture.pmremVersion=u.pmremVersion,t.set(u,m),u.addEventListener("dispose",h),m.texture):null}}}return u}function o(u,d){return d===Oa?u.mapping=gi:d===Ua&&(u.mapping=Fi),u}function c(u){let d=0,g=6;for(let y=0;y<g;y++)u[y]!==void 0&&d++;return d===g}function l(u){let d=u.target;d.removeEventListener("dispose",l);let g=e.get(d);g!==void 0&&(e.delete(d),g.dispose())}function h(u){let d=u.target;d.removeEventListener("dispose",h);let g=t.get(d);g!==void 0&&(t.delete(d),g.dispose())}function f(){e=new WeakMap,t=new WeakMap,n!==null&&(n.dispose(),n=null)}return{get:s,dispose:f}}function Rm(i){let e={};function t(n){if(e[n]!==void 0)return e[n];let s=i.getExtension(n);return e[n]=s,s}return{has:function(n){return t(n)!==null},init:function(){t("EXT_color_buffer_float"),t("WEBGL_clip_cull_distance"),t("OES_texture_float_linear"),t("EXT_color_buffer_half_float"),t("WEBGL_multisampled_render_to_texture"),t("WEBGL_render_shared_exponent")},get:function(n){let s=t(n);return s===null&&Ri("WebGLRenderer: "+n+" extension not supported."),s}}}function Cm(i,e,t,n){let s={},r=new WeakMap;function a(f){let u=f.target;u.index!==null&&e.remove(u.index);for(let g in u.attributes)e.remove(u.attributes[g]);u.removeEventListener("dispose",a),delete s[u.id];let d=r.get(u);d&&(e.remove(d),r.delete(u)),n.releaseStatesOfGeometry(u),u.isInstancedBufferGeometry===!0&&delete u._maxInstanceCount,t.memory.geometries--}function o(f,u){return s[u.id]===!0||(u.addEventListener("dispose",a),s[u.id]=!0,t.memory.geometries++),u}function c(f){let u=f.attributes;for(let d in u)e.update(u[d],i.ARRAY_BUFFER)}function l(f){let u=[],d=f.index,g=f.attributes.position,y=0;if(g===void 0)return;if(d!==null){let T=d.array;y=d.version;for(let R=0,v=T.length;R<v;R+=3){let b=T[R+0],S=T[R+1],A=T[R+2];u.push(b,S,S,A,A,b)}}else{let T=g.array;y=g.version;for(let R=0,v=T.length/3-1;R<v;R+=3){let b=R+0,S=R+1,A=R+2;u.push(b,S,S,A,A,b)}}let m=new(g.count>=65535?er:Qs)(u,1);m.version=y;let p=r.get(f);p&&e.remove(p),r.set(f,m)}function h(f){let u=r.get(f);if(u){let d=f.index;d!==null&&u.version<d.version&&l(f)}else l(f);return r.get(f)}return{get:o,update:c,getWireframeAttribute:h}}function zm(i,e,t){let n;function s(f){n=f}let r,a;function o(f){r=f.type,a=f.bytesPerElement}function c(f,u){i.drawElements(n,u,r,f*a),t.update(u,n,1)}function l(f,u,d){d!==0&&(i.drawElementsInstanced(n,u,r,f*a,d),t.update(u,n,d))}function h(f,u,d){if(d===0)return;e.get("WEBGL_multi_draw").multiDrawElementsWEBGL(n,u,0,r,f,0,d);let y=0;for(let m=0;m<d;m++)y+=u[m];t.update(y,n,1)}this.setMode=s,this.setIndex=o,this.render=c,this.renderInstances=l,this.renderMultiDraw=h}function Im(i){let e={geometries:0,textures:0},t={frame:0,calls:0,triangles:0,points:0,lines:0};function n(r,a,o){switch(t.calls++,a){case i.TRIANGLES:t.triangles+=o*(r/3);break;case i.LINES:t.lines+=o*(r/2);break;case i.LINE_STRIP:t.lines+=o*(r-1);break;case i.LINE_LOOP:t.lines+=o*r;break;case i.POINTS:t.points+=o*r;break;default:ze("WebGLInfo: Unknown draw mode:",a);break}}function s(){t.calls=0,t.triangles=0,t.points=0,t.lines=0}return{memory:e,render:t,programs:null,autoReset:!0,reset:s,update:n}}function Pm(i,e,t){let n=new WeakMap,s=new et;function r(a,o,c){let l=a.morphTargetInfluences,h=o.morphAttributes.position||o.morphAttributes.normal||o.morphAttributes.color,f=h!==void 0?h.length:0,u=n.get(o);if(u===void 0||u.count!==f){let E=function(){A.dispose(),n.delete(o),o.removeEventListener("dispose",E)};u!==void 0&&u.texture.dispose();let d=o.morphAttributes.position!==void 0,g=o.morphAttributes.normal!==void 0,y=o.morphAttributes.color!==void 0,m=o.morphAttributes.position||[],p=o.morphAttributes.normal||[],T=o.morphAttributes.color||[],R=0;d===!0&&(R=1),g===!0&&(R=2),y===!0&&(R=3);let v=o.attributes.position.count*R,b=1;v>e.maxTextureSize&&(b=Math.ceil(v/e.maxTextureSize),v=e.maxTextureSize);let S=new Float32Array(v*b*4*f),A=new Js(S,v,b,f);A.type=nn,A.needsUpdate=!0;let _=R*4;for(let P=0;P<f;P++){let N=m[P],k=p[P],H=T[P],L=v*b*4*P;for(let V=0;V<N.count;V++){let K=V*_;d===!0&&(s.fromBufferAttribute(N,V),S[L+K+0]=s.x,S[L+K+1]=s.y,S[L+K+2]=s.z,S[L+K+3]=0),g===!0&&(s.fromBufferAttribute(k,V),S[L+K+4]=s.x,S[L+K+5]=s.y,S[L+K+6]=s.z,S[L+K+7]=0),y===!0&&(s.fromBufferAttribute(H,V),S[L+K+8]=s.x,S[L+K+9]=s.y,S[L+K+10]=s.z,S[L+K+11]=H.itemSize===4?s.w:1)}}u={count:f,texture:A,size:new Oe(v,b)},n.set(o,u),o.addEventListener("dispose",E)}if(a.isInstancedMesh===!0&&a.morphTexture!==null)c.getUniforms().setValue(i,"morphTexture",a.morphTexture,t);else{let d=0;for(let y=0;y<l.length;y++)d+=l[y];let g=o.morphTargetsRelative?1:1-d;c.getUniforms().setValue(i,"morphTargetBaseInfluence",g),c.getUniforms().setValue(i,"morphTargetInfluences",l)}c.getUniforms().setValue(i,"morphTargetsTexture",u.texture,t),c.getUniforms().setValue(i,"morphTargetsTextureSize",u.size)}return{update:r}}function Lm(i,e,t,n,s){let r=new WeakMap;function a(l){let h=s.render.frame,f=l.geometry,u=e.get(l,f);if(r.get(u)!==h&&(e.update(u),r.set(u,h)),l.isInstancedMesh&&(l.hasEventListener("dispose",c)===!1&&l.addEventListener("dispose",c),r.get(l)!==h&&(t.update(l.instanceMatrix,i.ARRAY_BUFFER),l.instanceColor!==null&&t.update(l.instanceColor,i.ARRAY_BUFFER),r.set(l,h))),l.isSkinnedMesh){let d=l.skeleton;r.get(d)!==h&&(d.update(),r.set(d,h))}return u}function o(){r=new WeakMap}function c(l){let h=l.target;h.removeEventListener("dispose",c),n.releaseStatesOfObject(h),t.remove(h.instanceMatrix),h.instanceColor!==null&&t.remove(h.instanceColor)}return{update:a,dispose:o}}var Nm={[Nc]:"LINEAR_TONE_MAPPING",[Dc]:"REINHARD_TONE_MAPPING",[Oc]:"CINEON_TONE_MAPPING",[Uc]:"ACES_FILMIC_TONE_MAPPING",[Bc]:"AGX_TONE_MAPPING",[kc]:"NEUTRAL_TONE_MAPPING",[Fc]:"CUSTOM_TONE_MAPPING"};function Dm(i,e,t,n,s,r){let a=new Wt(e,t,{type:i,depthBuffer:s,stencilBuffer:r,samples:n?4:0,storeMultisampledDepthBuffer:!1,storeMultisampledStencilBuffer:!1,resolveDepthBuffer:!1,resolveStencilBuffer:!1}),o=null,c=null,l=new Nt;l.setAttribute("position",new Bt([-1,3,0,-1,-1,0,3,-1,0],3)),l.setAttribute("uv",new Bt([0,2,0,0,2,0],2));let h=new Sa({uniforms:{tDiffuse:{value:null}},vertexShader:`
			precision highp float;

			uniform mat4 modelViewMatrix;
			uniform mat4 projectionMatrix;

			attribute vec3 position;
			attribute vec2 uv;

			varying vec2 vUv;

			void main() {
				vUv = uv;
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}`,fragmentShader:`
			precision highp float;

			uniform sampler2D tDiffuse;

			varying vec2 vUv;

			#include <tonemapping_pars_fragment>
			#include <colorspace_pars_fragment>

			void main() {
				gl_FragColor = texture2D( tDiffuse, vUv );

				#ifdef LINEAR_TONE_MAPPING
					gl_FragColor.rgb = LinearToneMapping( gl_FragColor.rgb );
				#elif defined( REINHARD_TONE_MAPPING )
					gl_FragColor.rgb = ReinhardToneMapping( gl_FragColor.rgb );
				#elif defined( CINEON_TONE_MAPPING )
					gl_FragColor.rgb = CineonToneMapping( gl_FragColor.rgb );
				#elif defined( ACES_FILMIC_TONE_MAPPING )
					gl_FragColor.rgb = ACESFilmicToneMapping( gl_FragColor.rgb );
				#elif defined( AGX_TONE_MAPPING )
					gl_FragColor.rgb = AgXToneMapping( gl_FragColor.rgb );
				#elif defined( NEUTRAL_TONE_MAPPING )
					gl_FragColor.rgb = NeutralToneMapping( gl_FragColor.rgb );
				#elif defined( CUSTOM_TONE_MAPPING )
					gl_FragColor.rgb = CustomToneMapping( gl_FragColor.rgb );
				#endif

				#ifdef SRGB_TRANSFER
					gl_FragColor = sRGBTransferOETF( gl_FragColor );
				#endif
			}`,depthTest:!1,depthWrite:!1}),f=new Ct(l,h),u=new Mi(-1,1,1,-1,0,1),d=null,g=null,y=!1,m,p=null,T=[],R=!1;this.setSize=function(v,b){a.setSize(v,b),o!==null&&o.setSize(v,b),c!==null&&c.setSize(v,b);for(let S=0;S<T.length;S++){let A=T[S];A.setSize&&A.setSize(v,b)}},this.setEffects=function(v){T=v,R=T.length>0&&T[0].isRenderPass===!0;let b=a.width,S=a.height;T.length>0&&o===null&&(o=new Wt(b,S,{type:wn,depthBuffer:!1,stencilBuffer:!1}),c=new Wt(b,S,{type:wn,depthBuffer:!1,stencilBuffer:!1}));for(let A=0;A<T.length;A++){let _=T[A];_.setSize&&_.setSize(b,S)}},this.begin=function(v,b){if(y||v.toneMapping===vn&&T.length===0)return!1;if(p=b,b!==null){let S=b.width,A=b.height;(a.width!==S||a.height!==A)&&this.setSize(S,A)}return R===!1&&v.setRenderTarget(a),m=v.toneMapping,v.toneMapping=vn,!0},this.hasRenderPass=function(){return R},this.end=function(v,b){v.toneMapping=m,y=!0;let S=a,A=o;for(let _=0;_<T.length;_++){let E=T[_];E.enabled!==!1&&(E.render(v,A,S,b),E.needsSwap!==!1&&(S=A,A=A===o?c:o))}if(d!==v.outputColorSpace||g!==v.toneMapping){d=v.outputColorSpace,g=v.toneMapping,h.defines={},Fe.getTransfer(d)===$e&&(h.defines.SRGB_TRANSFER="");let _=Nm[g];_&&(h.defines[_]=""),h.needsUpdate=!0}h.uniforms.tDiffuse.value=S.texture,v.setRenderTarget(p),v.render(f,u),p=null,y=!1},this.isCompositing=function(){return y},this.dispose=function(){a.dispose(),o!==null&&o.dispose(),c!==null&&c.dispose(),l.dispose(),h.dispose()}}var ef=new Rt,cl=new pi(1,1),tf=new Js,nf=new xa,sf=new or,Du=[],Ou=[],Uu=new Float32Array(16),Fu=new Float32Array(9),Bu=new Float32Array(4);function Ns(i,e,t){let n=i[0];if(n<=0||n>0)return i;let s=e*t,r=Du[s];if(r===void 0&&(r=new Float32Array(s),Du[s]=r),e!==0){n.toArray(r,0);for(let a=1,o=0;a!==e;++a)o+=t,i[a].toArray(r,o)}return r}function St(i,e){if(i.length!==e.length)return!1;for(let t=0,n=i.length;t<n;t++)if(i[t]!==e[t])return!1;return!0}function wt(i,e){for(let t=0,n=e.length;t<n;t++)i[t]=e[t]}function Io(i,e){let t=Ou[e];t===void 0&&(t=new Int32Array(e),Ou[e]=t);for(let n=0;n!==e;++n)t[n]=i.allocateTextureUnit();return t}function Om(i,e){let t=this.cache;t[0]!==e&&(i.uniform1f(this.addr,e),t[0]=e)}function Um(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y)&&(i.uniform2f(this.addr,e.x,e.y),t[0]=e.x,t[1]=e.y);else{if(St(t,e))return;i.uniform2fv(this.addr,e),wt(t,e)}}function Fm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z)&&(i.uniform3f(this.addr,e.x,e.y,e.z),t[0]=e.x,t[1]=e.y,t[2]=e.z);else if(e.r!==void 0)(t[0]!==e.r||t[1]!==e.g||t[2]!==e.b)&&(i.uniform3f(this.addr,e.r,e.g,e.b),t[0]=e.r,t[1]=e.g,t[2]=e.b);else{if(St(t,e))return;i.uniform3fv(this.addr,e),wt(t,e)}}function Bm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z||t[3]!==e.w)&&(i.uniform4f(this.addr,e.x,e.y,e.z,e.w),t[0]=e.x,t[1]=e.y,t[2]=e.z,t[3]=e.w);else{if(St(t,e))return;i.uniform4fv(this.addr,e),wt(t,e)}}function km(i,e){let t=this.cache,n=e.elements;if(n===void 0){if(St(t,e))return;i.uniformMatrix2fv(this.addr,!1,e),wt(t,e)}else{if(St(t,n))return;Bu.set(n),i.uniformMatrix2fv(this.addr,!1,Bu),wt(t,n)}}function Vm(i,e){let t=this.cache,n=e.elements;if(n===void 0){if(St(t,e))return;i.uniformMatrix3fv(this.addr,!1,e),wt(t,e)}else{if(St(t,n))return;Fu.set(n),i.uniformMatrix3fv(this.addr,!1,Fu),wt(t,n)}}function Gm(i,e){let t=this.cache,n=e.elements;if(n===void 0){if(St(t,e))return;i.uniformMatrix4fv(this.addr,!1,e),wt(t,e)}else{if(St(t,n))return;Uu.set(n),i.uniformMatrix4fv(this.addr,!1,Uu),wt(t,n)}}function Hm(i,e){let t=this.cache;t[0]!==e&&(i.uniform1i(this.addr,e),t[0]=e)}function Wm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y)&&(i.uniform2i(this.addr,e.x,e.y),t[0]=e.x,t[1]=e.y);else{if(St(t,e))return;i.uniform2iv(this.addr,e),wt(t,e)}}function Xm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z)&&(i.uniform3i(this.addr,e.x,e.y,e.z),t[0]=e.x,t[1]=e.y,t[2]=e.z);else{if(St(t,e))return;i.uniform3iv(this.addr,e),wt(t,e)}}function qm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z||t[3]!==e.w)&&(i.uniform4i(this.addr,e.x,e.y,e.z,e.w),t[0]=e.x,t[1]=e.y,t[2]=e.z,t[3]=e.w);else{if(St(t,e))return;i.uniform4iv(this.addr,e),wt(t,e)}}function Ym(i,e){let t=this.cache;t[0]!==e&&(i.uniform1ui(this.addr,e),t[0]=e)}function Zm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y)&&(i.uniform2ui(this.addr,e.x,e.y),t[0]=e.x,t[1]=e.y);else{if(St(t,e))return;i.uniform2uiv(this.addr,e),wt(t,e)}}function Km(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z)&&(i.uniform3ui(this.addr,e.x,e.y,e.z),t[0]=e.x,t[1]=e.y,t[2]=e.z);else{if(St(t,e))return;i.uniform3uiv(this.addr,e),wt(t,e)}}function Jm(i,e){let t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z||t[3]!==e.w)&&(i.uniform4ui(this.addr,e.x,e.y,e.z,e.w),t[0]=e.x,t[1]=e.y,t[2]=e.z,t[3]=e.w);else{if(St(t,e))return;i.uniform4uiv(this.addr,e),wt(t,e)}}function $m(i,e,t){let n=this.cache,s=t.allocateTextureUnit();n[0]!==s&&(i.uniform1i(this.addr,s),n[0]=s);let r;this.type===i.SAMPLER_2D_SHADOW?(cl.compareFunction=t.isReversedDepthBuffer()?wo:So,r=cl):r=ef,t.setTexture2D(e||r,s)}function jm(i,e,t){let n=this.cache,s=t.allocateTextureUnit();n[0]!==s&&(i.uniform1i(this.addr,s),n[0]=s),t.setTexture3D(e||nf,s)}function Qm(i,e,t){let n=this.cache,s=t.allocateTextureUnit();n[0]!==s&&(i.uniform1i(this.addr,s),n[0]=s),t.setTextureCube(e||sf,s)}function eM(i,e,t){let n=this.cache,s=t.allocateTextureUnit();n[0]!==s&&(i.uniform1i(this.addr,s),n[0]=s),t.setTexture2DArray(e||tf,s)}function tM(i){switch(i){case 5126:return Om;case 35664:return Um;case 35665:return Fm;case 35666:return Bm;case 35674:return km;case 35675:return Vm;case 35676:return Gm;case 5124:case 35670:return Hm;case 35667:case 35671:return Wm;case 35668:case 35672:return Xm;case 35669:case 35673:return qm;case 5125:return Ym;case 36294:return Zm;case 36295:return Km;case 36296:return Jm;case 35678:case 36198:case 36298:case 36306:case 35682:return $m;case 35679:case 36299:case 36307:return jm;case 35680:case 36300:case 36308:case 36293:return Qm;case 36289:case 36303:case 36311:case 36292:return eM}}function nM(i,e){i.uniform1fv(this.addr,e)}function iM(i,e){let t=Ns(e,this.size,2);i.uniform2fv(this.addr,t)}function sM(i,e){let t=Ns(e,this.size,3);i.uniform3fv(this.addr,t)}function rM(i,e){let t=Ns(e,this.size,4);i.uniform4fv(this.addr,t)}function aM(i,e){let t=Ns(e,this.size,4);i.uniformMatrix2fv(this.addr,!1,t)}function oM(i,e){let t=Ns(e,this.size,9);i.uniformMatrix3fv(this.addr,!1,t)}function cM(i,e){let t=Ns(e,this.size,16);i.uniformMatrix4fv(this.addr,!1,t)}function lM(i,e){i.uniform1iv(this.addr,e)}function hM(i,e){i.uniform2iv(this.addr,e)}function uM(i,e){i.uniform3iv(this.addr,e)}function fM(i,e){i.uniform4iv(this.addr,e)}function dM(i,e){i.uniform1uiv(this.addr,e)}function pM(i,e){i.uniform2uiv(this.addr,e)}function mM(i,e){i.uniform3uiv(this.addr,e)}function MM(i,e){i.uniform4uiv(this.addr,e)}function gM(i,e,t){let n=this.cache,s=e.length,r=Io(t,s);St(n,r)||(i.uniform1iv(this.addr,r),wt(n,r));let a;this.type===i.SAMPLER_2D_SHADOW?a=cl:a=ef;for(let o=0;o!==s;++o)t.setTexture2D(e[o]||a,r[o])}function _M(i,e,t){let n=this.cache,s=e.length,r=Io(t,s);St(n,r)||(i.uniform1iv(this.addr,r),wt(n,r));for(let a=0;a!==s;++a)t.setTexture3D(e[a]||nf,r[a])}function xM(i,e,t){let n=this.cache,s=e.length,r=Io(t,s);St(n,r)||(i.uniform1iv(this.addr,r),wt(n,r));for(let a=0;a!==s;++a)t.setTextureCube(e[a]||sf,r[a])}function yM(i,e,t){let n=this.cache,s=e.length,r=Io(t,s);St(n,r)||(i.uniform1iv(this.addr,r),wt(n,r));for(let a=0;a!==s;++a)t.setTexture2DArray(e[a]||tf,r[a])}function vM(i){switch(i){case 5126:return nM;case 35664:return iM;case 35665:return sM;case 35666:return rM;case 35674:return aM;case 35675:return oM;case 35676:return cM;case 5124:case 35670:return lM;case 35667:case 35671:return hM;case 35668:case 35672:return uM;case 35669:case 35673:return fM;case 5125:return dM;case 36294:return pM;case 36295:return mM;case 36296:return MM;case 35678:case 36198:case 36298:case 36306:case 35682:return gM;case 35679:case 36299:case 36307:return _M;case 35680:case 36300:case 36308:case 36293:return xM;case 36289:case 36303:case 36311:case 36292:return yM}}var ll=class{constructor(e,t,n){this.id=e,this.addr=n,this.cache=[],this.type=t.type,this.setValue=tM(t.type)}},hl=class{constructor(e,t,n){this.id=e,this.addr=n,this.cache=[],this.type=t.type,this.size=t.size,this.setValue=vM(t.type)}},ul=class{constructor(e){this.id=e,this.seq=[],this.map={}}setValue(e,t,n){let s=this.seq;for(let r=0,a=s.length;r!==a;++r){let o=s[r];o.setValue(e,t[o.id],n)}}},al=/(\w+)(\])?(\[|\.)?/g;function ku(i,e){i.seq.push(e),i.map[e.id]=e}function bM(i,e,t){let n=i.name,s=n.length;for(al.lastIndex=0;;){let r=al.exec(n),a=al.lastIndex,o=r[1],c=r[2]==="]",l=r[3];if(c&&(o=o|0),l===void 0||l==="["&&a+2===s){ku(t,l===void 0?new ll(o,i,e):new hl(o,i,e));break}else{let f=t.map[o];f===void 0&&(f=new ul(o),ku(t,f)),t=f}}}var Ls=class{constructor(e,t){this.seq=[],this.map={};let n=e.getProgramParameter(t,e.ACTIVE_UNIFORMS);for(let a=0;a<n;++a){let o=e.getActiveUniform(t,a),c=e.getUniformLocation(t,o.name);bM(o,c,this)}let s=[],r=[];for(let a of this.seq)a.type===e.SAMPLER_2D_SHADOW||a.type===e.SAMPLER_CUBE_SHADOW||a.type===e.SAMPLER_2D_ARRAY_SHADOW?s.push(a):r.push(a);s.length>0&&(this.seq=s.concat(r))}setValue(e,t,n,s){let r=this.map[t];r!==void 0&&r.setValue(e,n,s)}setOptional(e,t,n){let s=t[n];s!==void 0&&this.setValue(e,n,s)}static upload(e,t,n,s){for(let r=0,a=t.length;r!==a;++r){let o=t[r],c=n[o.id];c.needsUpdate!==!1&&o.setValue(e,c.value,s)}}static seqWithValue(e,t){let n=[];for(let s=0,r=e.length;s!==r;++s){let a=e[s];a.id in t&&n.push(a)}return n}};function Vu(i,e,t){let n=i.createShader(e);return i.shaderSource(n,t),i.compileShader(n),n}var SM=37297,wM=0;function TM(i,e){let t=i.split(`
`),n=[],s=Math.max(e-6,0),r=Math.min(e+6,t.length);for(let a=s;a<r;a++){let o=a+1;n.push(`${o===e?">":" "} ${o}: ${t[a]}`)}return n.join(`
`)}var Gu=new Ie;function EM(i){Fe._getMatrix(Gu,Fe.workingColorSpace,i);let e=`mat3( ${Gu.elements.map(t=>t.toFixed(4))} )`;switch(Fe.getTransfer(i)){case Zs:return[e,"LinearTransferOETF"];case $e:return[e,"sRGBTransferOETF"];default:return be("WebGLProgram: Unsupported color space: ",i),[e,"LinearTransferOETF"]}}function Hu(i,e,t){let n=i.getShaderParameter(e,i.COMPILE_STATUS),r=(i.getShaderInfoLog(e)||"").trim();if(n&&r==="")return"";let a=/ERROR: 0:(\d+)/.exec(r);if(a){let o=parseInt(a[1]);return t.toUpperCase()+`

`+r+`

`+TM(i.getShaderSource(e),o)}else return r}function AM(i,e){let t=EM(e);return[`vec4 ${i}( vec4 value ) {`,`	return ${t[1]}( vec4( value.rgb * ${t[0]}, value.a ) );`,"}"].join(`
`)}var RM={[Nc]:"Linear",[Dc]:"Reinhard",[Oc]:"Cineon",[Uc]:"ACESFilmic",[Bc]:"AgX",[kc]:"Neutral",[Fc]:"Custom"};function CM(i,e){let t=RM[e];return t===void 0?(be("WebGLProgram: Unsupported toneMapping:",e),"vec3 "+i+"( vec3 color ) { return LinearToneMapping( color ); }"):"vec3 "+i+"( vec3 color ) { return "+t+"ToneMapping( color ); }"}var Eo=new O;function zM(){Fe.getLuminanceCoefficients(Eo);let i=Eo.x.toFixed(4),e=Eo.y.toFixed(4),t=Eo.z.toFixed(4);return["float luminance( const in vec3 rgb ) {",`	const vec3 weights = vec3( ${i}, ${e}, ${t} );`,"	return dot( weights, rgb );","}"].join(`
`)}function IM(i){return[i.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":"",i.extensionMultiDraw?"#extension GL_ANGLE_multi_draw : require":""].filter(zr).join(`
`)}function PM(i){let e=[];for(let t in i){let n=i[t];n!==!1&&e.push("#define "+t+" "+n)}return e.join(`
`)}function LM(i,e){let t={},n=i.getProgramParameter(e,i.ACTIVE_ATTRIBUTES);for(let s=0;s<n;s++){let r=i.getActiveAttrib(e,s),a=r.name,o=1;r.type===i.FLOAT_MAT2&&(o=2),r.type===i.FLOAT_MAT3&&(o=3),r.type===i.FLOAT_MAT4&&(o=4),t[a]={type:r.type,location:i.getAttribLocation(e,a),locationSize:o}}return t}function zr(i){return i!==""}function Wu(i,e){let t=e.numSpotLightShadows+e.numSpotLightMaps-e.numSpotLightShadowsWithMaps;return i.replace(/NUM_SUN_LIGHTS/g,e.numSunLights).replace(/NUM_DIR_LIGHTS/g,e.numDirLights).replace(/NUM_SPOT_LIGHTS/g,e.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,e.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,t).replace(/NUM_RECT_AREA_LIGHTS/g,e.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,e.numPointLights).replace(/NUM_HEMI_LIGHTS/g,e.numHemiLights).replace(/NUM_SUN_LIGHT_SHADOWS/g,e.numSunLightShadows).replace(/NUM_DIR_LIGHT_SHADOWS/g,e.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,e.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,e.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,e.numPointLightShadows)}function Xu(i,e){return i.replace(/NUM_CLIPPING_PLANES/g,e.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,e.numClippingPlanes-e.numClipIntersection)}var NM=/^[ \t]*#include +<([\w\d./]+)>/gm;function fl(i){return i.replace(NM,OM)}var DM=new Map;function OM(i,e){let t=Ue[e];if(t===void 0){let n=DM.get(e);if(n!==void 0)t=Ue[n],be('WebGLRenderer: Shader chunk "%s" has been deprecated. Use "%s" instead.',e,n);else throw new Error("THREE.WebGLProgram: Can not resolve #include <"+e+">")}return fl(t)}var UM=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function qu(i){return i.replace(UM,FM)}function FM(i,e,t,n){let s="";for(let r=parseInt(e);r<parseInt(t);r++)s+=n.replace(/\[\s*i\s*\]/g,"[ "+r+" ]").replace(/UNROLLED_LOOP_INDEX/g,r);return s}function Yu(i){let e=`precision ${i.precision} float;
	precision ${i.precision} int;
	precision ${i.precision} sampler2D;
	precision ${i.precision} samplerCube;
	precision ${i.precision} sampler3D;
	precision ${i.precision} sampler2DArray;
	precision ${i.precision} sampler2DShadow;
	precision ${i.precision} samplerCubeShadow;
	precision ${i.precision} sampler2DArrayShadow;
	precision ${i.precision} isampler2D;
	precision ${i.precision} isampler3D;
	precision ${i.precision} isamplerCube;
	precision ${i.precision} isampler2DArray;
	precision ${i.precision} usampler2D;
	precision ${i.precision} usampler3D;
	precision ${i.precision} usamplerCube;
	precision ${i.precision} usampler2DArray;
	`;return i.precision==="highp"?e+=`
#define HIGH_PRECISION`:i.precision==="mediump"?e+=`
#define MEDIUM_PRECISION`:i.precision==="lowp"&&(e+=`
#define LOW_PRECISION`),e}var BM={[_r]:"SHADOWMAP_TYPE_PCF",[Ts]:"SHADOWMAP_TYPE_VSM"};function kM(i){return BM[i.shadowMapType]||"SHADOWMAP_TYPE_BASIC"}var VM={[gi]:"ENVMAP_TYPE_CUBE",[Fi]:"ENVMAP_TYPE_CUBE",[xr]:"ENVMAP_TYPE_CUBE_UV"};function GM(i){return i.envMap===!1?"ENVMAP_TYPE_CUBE":VM[i.envMapMode]||"ENVMAP_TYPE_CUBE"}var HM={[Fi]:"ENVMAP_MODE_REFRACTION"};function WM(i){return i.envMap===!1?"ENVMAP_MODE_REFLECTION":HM[i.envMapMode]||"ENVMAP_MODE_REFLECTION"}var XM={[Da]:"ENVMAP_BLENDING_MULTIPLY",[hu]:"ENVMAP_BLENDING_MIX",[uu]:"ENVMAP_BLENDING_ADD"};function qM(i){return i.envMap===!1?"ENVMAP_BLENDING_NONE":XM[i.combine]||"ENVMAP_BLENDING_NONE"}function YM(i){let e=i.envMapCubeUVHeight;if(e===null)return null;let t=Math.log2(e)-2,n=1/e;return{texelWidth:1/(3*Math.max(Math.pow(2,t),112)),texelHeight:n,maxMip:t}}function ZM(i,e,t,n){let s=i.getContext(),r=t.defines,a=t.vertexShader,o=t.fragmentShader,c=kM(t),l=GM(t),h=WM(t),f=qM(t),u=YM(t),d=IM(t),g=PM(r),y=s.createProgram(),m,p,T=t.glslVersion?"#version "+t.glslVersion+`
`:"";t.isRawShaderMaterial?(m=["#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g].filter(zr).join(`
`),m.length>0&&(m+=`
`),p=["#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g].filter(zr).join(`
`),p.length>0&&(p+=`
`)):(m=[Yu(t),"#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g,t.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",t.batching?"#define USE_BATCHING":"",t.batchingColor?"#define USE_BATCHING_COLOR":"",t.instancing?"#define USE_INSTANCING":"",t.instancingColor?"#define USE_INSTANCING_COLOR":"",t.instancingMorph?"#define USE_INSTANCING_MORPH":"",t.useFog&&t.fog?"#define USE_FOG":"",t.useFog&&t.fogExp2?"#define FOG_EXP2":"",t.map?"#define USE_MAP":"",t.envMap?"#define USE_ENVMAP":"",t.envMap?"#define "+h:"",t.lightMap?"#define USE_LIGHTMAP":"",t.aoMap?"#define USE_AOMAP":"",t.bumpMap?"#define USE_BUMPMAP":"",t.normalMap?"#define USE_NORMALMAP":"",t.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",t.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",t.displacementMap?"#define USE_DISPLACEMENTMAP":"",t.emissiveMap?"#define USE_EMISSIVEMAP":"",t.anisotropy?"#define USE_ANISOTROPY":"",t.anisotropyMap?"#define USE_ANISOTROPYMAP":"",t.clearcoatMap?"#define USE_CLEARCOATMAP":"",t.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",t.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",t.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",t.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",t.specularMap?"#define USE_SPECULARMAP":"",t.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",t.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",t.roughnessMap?"#define USE_ROUGHNESSMAP":"",t.metalnessMap?"#define USE_METALNESSMAP":"",t.alphaMap?"#define USE_ALPHAMAP":"",t.alphaHash?"#define USE_ALPHAHASH":"",t.transmission?"#define USE_TRANSMISSION":"",t.transmissionMap?"#define USE_TRANSMISSIONMAP":"",t.thicknessMap?"#define USE_THICKNESSMAP":"",t.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",t.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",t.mapUv?"#define MAP_UV "+t.mapUv:"",t.alphaMapUv?"#define ALPHAMAP_UV "+t.alphaMapUv:"",t.lightMapUv?"#define LIGHTMAP_UV "+t.lightMapUv:"",t.aoMapUv?"#define AOMAP_UV "+t.aoMapUv:"",t.emissiveMapUv?"#define EMISSIVEMAP_UV "+t.emissiveMapUv:"",t.bumpMapUv?"#define BUMPMAP_UV "+t.bumpMapUv:"",t.normalMapUv?"#define NORMALMAP_UV "+t.normalMapUv:"",t.displacementMapUv?"#define DISPLACEMENTMAP_UV "+t.displacementMapUv:"",t.metalnessMapUv?"#define METALNESSMAP_UV "+t.metalnessMapUv:"",t.roughnessMapUv?"#define ROUGHNESSMAP_UV "+t.roughnessMapUv:"",t.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+t.anisotropyMapUv:"",t.clearcoatMapUv?"#define CLEARCOATMAP_UV "+t.clearcoatMapUv:"",t.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+t.clearcoatNormalMapUv:"",t.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+t.clearcoatRoughnessMapUv:"",t.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+t.iridescenceMapUv:"",t.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+t.iridescenceThicknessMapUv:"",t.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+t.sheenColorMapUv:"",t.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+t.sheenRoughnessMapUv:"",t.specularMapUv?"#define SPECULARMAP_UV "+t.specularMapUv:"",t.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+t.specularColorMapUv:"",t.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+t.specularIntensityMapUv:"",t.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+t.transmissionMapUv:"",t.thicknessMapUv?"#define THICKNESSMAP_UV "+t.thicknessMapUv:"",t.vertexTangents&&t.flatShading===!1?"#define USE_TANGENT":"",t.vertexNormals?"#define HAS_NORMAL":"",t.vertexColors?"#define USE_COLOR":"",t.vertexAlphas?"#define USE_COLOR_ALPHA":"",t.vertexUv1s?"#define USE_UV1":"",t.vertexUv2s?"#define USE_UV2":"",t.vertexUv3s?"#define USE_UV3":"",t.pointsUvs?"#define USE_POINTS_UV":"",t.flatShading?"#define FLAT_SHADED":"",t.skinning?"#define USE_SKINNING":"",t.morphTargets?"#define USE_MORPHTARGETS":"",t.morphNormals&&t.flatShading===!1?"#define USE_MORPHNORMALS":"",t.morphColors?"#define USE_MORPHCOLORS":"",t.morphTargetsCount>0?"#define MORPHTARGETS_TEXTURE_STRIDE "+t.morphTextureStride:"",t.morphTargetsCount>0?"#define MORPHTARGETS_COUNT "+t.morphTargetsCount:"",t.doubleSided?"#define DOUBLE_SIDED":"",t.flipSided?"#define FLIP_SIDED":"",t.shadowMapEnabled?"#define USE_SHADOWMAP":"",t.shadowMapEnabled?"#define "+c:"",t.sizeAttenuation?"#define USE_SIZEATTENUATION":"",t.numLightProbes>0?"#define USE_LIGHT_PROBES":"",t.logarithmicDepthBuffer?"#define USE_LOGARITHMIC_DEPTH_BUFFER":"",t.reversedDepthBuffer?"#define USE_REVERSED_DEPTH_BUFFER":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","#ifdef USE_INSTANCING_MORPH","	uniform sampler2D morphTexture;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(zr).join(`
`),p=[Yu(t),"#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g,t.useFog&&t.fog?"#define USE_FOG":"",t.useFog&&t.fogExp2?"#define FOG_EXP2":"",t.alphaToCoverage?"#define ALPHA_TO_COVERAGE":"",t.map?"#define USE_MAP":"",t.matcap?"#define USE_MATCAP":"",t.envMap?"#define USE_ENVMAP":"",t.envMap?"#define "+l:"",t.envMap?"#define "+h:"",t.envMap?"#define "+f:"",u?"#define CUBEUV_TEXEL_WIDTH "+u.texelWidth:"",u?"#define CUBEUV_TEXEL_HEIGHT "+u.texelHeight:"",u?"#define CUBEUV_MAX_MIP "+u.maxMip+".0":"",t.lightMap?"#define USE_LIGHTMAP":"",t.aoMap?"#define USE_AOMAP":"",t.bumpMap?"#define USE_BUMPMAP":"",t.normalMap?"#define USE_NORMALMAP":"",t.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",t.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",t.packedNormalMap?"#define USE_PACKED_NORMALMAP":"",t.emissiveMap?"#define USE_EMISSIVEMAP":"",t.anisotropy?"#define USE_ANISOTROPY":"",t.anisotropyMap?"#define USE_ANISOTROPYMAP":"",t.clearcoat?"#define USE_CLEARCOAT":"",t.clearcoatMap?"#define USE_CLEARCOATMAP":"",t.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",t.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",t.dispersion?"#define USE_DISPERSION":"",t.retroreflection?"#define USE_RETROREFLECTION":"",t.iridescence?"#define USE_IRIDESCENCE":"",t.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",t.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",t.specularMap?"#define USE_SPECULARMAP":"",t.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",t.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",t.roughnessMap?"#define USE_ROUGHNESSMAP":"",t.metalnessMap?"#define USE_METALNESSMAP":"",t.alphaMap?"#define USE_ALPHAMAP":"",t.alphaTest?"#define USE_ALPHATEST":"",t.alphaHash?"#define USE_ALPHAHASH":"",t.sheen?"#define USE_SHEEN":"",t.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",t.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",t.transmission?"#define USE_TRANSMISSION":"",t.transmissionMap?"#define USE_TRANSMISSIONMAP":"",t.thicknessMap?"#define USE_THICKNESSMAP":"",t.vertexTangents&&t.flatShading===!1?"#define USE_TANGENT":"",t.vertexColors||t.instancingColor?"#define USE_COLOR":"",t.vertexAlphas||t.batchingColor?"#define USE_COLOR_ALPHA":"",t.vertexUv1s?"#define USE_UV1":"",t.vertexUv2s?"#define USE_UV2":"",t.vertexUv3s?"#define USE_UV3":"",t.pointsUvs?"#define USE_POINTS_UV":"",t.gradientMap?"#define USE_GRADIENTMAP":"",t.flatShading?"#define FLAT_SHADED":"",t.doubleSided?"#define DOUBLE_SIDED":"",t.flipSided?"#define FLIP_SIDED":"",t.shadowMapEnabled?"#define USE_SHADOWMAP":"",t.shadowMapEnabled?"#define "+c:"",t.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",t.numLightProbes>0?"#define USE_LIGHT_PROBES":"",t.numLightProbeGrids>0?"#define USE_LIGHT_PROBES_GRID":"",t.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",t.decodeVideoTextureEmissive?"#define DECODE_VIDEO_TEXTURE_EMISSIVE":"",t.logarithmicDepthBuffer?"#define USE_LOGARITHMIC_DEPTH_BUFFER":"",t.reversedDepthBuffer?"#define USE_REVERSED_DEPTH_BUFFER":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",t.toneMapping!==vn?"#define TONE_MAPPING":"",t.toneMapping!==vn?Ue.tonemapping_pars_fragment:"",t.toneMapping!==vn?CM("toneMapping",t.toneMapping):"",t.dithering?"#define DITHERING":"",t.opaque?"#define OPAQUE":"",Ue.colorspace_pars_fragment,AM("linearToOutputTexel",t.outputColorSpace),zM(),t.useDepthPacking?"#define DEPTH_PACKING "+t.depthPacking:"",`
`].filter(zr).join(`
`)),a=fl(a),a=Wu(a,t),a=Xu(a,t),o=fl(o),o=Wu(o,t),o=Xu(o,t),a=qu(a),o=qu(o),t.isRawShaderMaterial!==!0&&(T=`#version 300 es
`,m=[d,"#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+m,p=["#define varying in",t.glslVersion===Jc?"":"layout(location = 0) out highp vec4 pc_fragColor;",t.glslVersion===Jc?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+p);let R=T+m+a,v=T+p+o,b=Vu(s,s.VERTEX_SHADER,R),S=Vu(s,s.FRAGMENT_SHADER,v);s.attachShader(y,b),s.attachShader(y,S),t.index0AttributeName!==void 0?s.bindAttribLocation(y,0,t.index0AttributeName):t.hasPositionAttribute===!0&&s.bindAttribLocation(y,0,"position"),s.linkProgram(y);function A(N){if(i.debug.checkShaderErrors){let k=s.getProgramInfoLog(y)||"",H=s.getShaderInfoLog(b)||"",L=s.getShaderInfoLog(S)||"",V=k.trim(),K=H.trim(),Z=L.trim(),ne=!0,X=!0;if(s.getProgramParameter(y,s.LINK_STATUS)===!1)if(ne=!1,typeof i.debug.onShaderError=="function")i.debug.onShaderError(s,y,b,S);else{let Q=Hu(s,b,"vertex"),te=Hu(s,S,"fragment");ze("WebGLProgram: Shader Error "+s.getError()+" - VALIDATE_STATUS "+s.getProgramParameter(y,s.VALIDATE_STATUS)+`

Material Name: `+N.name+`
Material Type: `+N.type+`

Program Info Log: `+V+`
`+Q+`
`+te)}else V!==""?be("WebGLProgram: Program Info Log:",V):(K===""||Z==="")&&(X=!1);X&&(N.diagnostics={runnable:ne,programLog:V,vertexShader:{log:K,prefix:m},fragmentShader:{log:Z,prefix:p}})}s.deleteShader(b),s.deleteShader(S),_=new Ls(s,y),E=LM(s,y)}let _;this.getUniforms=function(){return _===void 0&&A(this),_};let E;this.getAttributes=function(){return E===void 0&&A(this),E};let P=t.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return P===!1&&(P=s.getProgramParameter(y,SM)),P},this.destroy=function(){n.releaseStatesOfProgram(this),s.deleteProgram(y),this.program=void 0},this.type=t.shaderType,this.name=t.shaderName,this.id=wM++,this.cacheKey=e,this.usedTimes=1,this.program=y,this.vertexShader=b,this.fragmentShader=S,this}var KM=0,dl=class{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(e,t,n){let s=this._getShaderCacheForMaterial(e);return s.has(t)===!1&&(s.add(t),t.usedTimes++),s.has(n)===!1&&(s.add(n),n.usedTimes++),this}remove(e){let t=this.materialCache.get(e);for(let n of t)n.usedTimes--,n.usedTimes===0&&this.shaderCache.delete(n.code);return this.materialCache.delete(e),this}getVertexShaderStage(e){return this._getShaderStage(e.vertexShader)}getFragmentShaderStage(e){return this._getShaderStage(e.fragmentShader)}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(e){let t=this.materialCache,n=t.get(e);return n===void 0&&(n=new Set,t.set(e,n)),n}_getShaderStage(e){let t=this.shaderCache,n=t.get(e);return n===void 0&&(n=new pl(e),t.set(e,n)),n}},pl=class{constructor(e){this.id=KM++,this.code=e,this.usedTimes=0}};function JM(i){return i===xi||i===wr||i===Tr}function $M(i,e,t,n,s,r){let a=new $s,o=new dl,c=new Set,l=[],h=new Map,f=n.logarithmicDepthBuffer,u=n.precision,d={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distance",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function g(_){return c.add(_),_===0?"uv":`uv${_}`}function y(_,E,P,N,k,H){let L=N.fog,V=k.geometry,K=_.isMeshStandardMaterial||_.isMeshLambertMaterial||_.isMeshPhongMaterial?N.environment:null,Z=_.isMeshStandardMaterial||_.isMeshLambertMaterial&&!_.envMap||_.isMeshPhongMaterial&&!_.envMap,ne=e.get(_.envMap||K,Z),X=ne&&ne.mapping===xr?ne.image.height:null,Q=d[_.type];_.precision!==null&&(u=n.getMaxPrecision(_.precision),u!==_.precision&&be("WebGLProgram.getParameters:",_.precision,"not supported, using",u,"instead."));let te=V.morphAttributes.position||V.morphAttributes.normal||V.morphAttributes.color,Ae=te!==void 0?te.length:0,Te=0;V.morphAttributes.position!==void 0&&(Te=1),V.morphAttributes.normal!==void 0&&(Te=2),V.morphAttributes.color!==void 0&&(Te=3);let st,Xe,Ze,q;if(Q){let at=Bn[Q];st=at.vertexShader,Xe=at.fragmentShader}else{st=_.vertexShader,Xe=_.fragmentShader;let at=o.getVertexShaderStage(_),Ke=o.getFragmentShaderStage(_);o.update(_,at,Ke),Ze=at.id,q=Ke.id}let j=i.getRenderTarget(),ge=i.state.buffers.depth.getReversed(),Pe=k.isInstancedMesh===!0,me=k.isBatchedMesh===!0,Be=!!_.map,yt=!!_.matcap,Ve=!!ne,Ye=!!_.aoMap,rt=!!_.lightMap,We=!!_.bumpMap&&_.wireframe===!1,lt=!!_.normalMap,Et=!!_.displacementMap,Ht=!!_.emissiveMap,ht=!!_.metalnessMap,Mt=!!_.roughnessMap,I=_.anisotropy>0,zt=_.clearcoat>0,je=_.dispersion>0,w=_.retroreflectivity>0,M=_.iridescence>0,D=_.sheen>0,B=_.transmission>0,W=I&&!!_.anisotropyMap,ie=zt&&!!_.clearcoatMap,se=zt&&!!_.clearcoatNormalMap,Y=zt&&!!_.clearcoatRoughnessMap,$=M&&!!_.iridescenceMap,re=M&&!!_.iridescenceThicknessMap,Se=D&&!!_.sheenColorMap,le=D&&!!_.sheenRoughnessMap,ae=!!_.specularMap,we=!!_.specularColorMap,Re=!!_.specularIntensityMap,Le=B&&!!_.transmissionMap,z=B&&!!_.thicknessMap,oe=!!_.gradientMap,J=!!_.alphaMap,ce=_.alphaTest>0,de=!!_.alphaHash,ee=!!_.extensions,Ee=vn;_.toneMapped&&(j===null||j.isXRRenderTarget===!0)&&(Ee=i.toneMapping);let ye={shaderID:Q,shaderType:_.type,shaderName:_.name,vertexShader:st,fragmentShader:Xe,defines:_.defines,customVertexShaderID:Ze,customFragmentShaderID:q,isRawShaderMaterial:_.isRawShaderMaterial===!0,glslVersion:_.glslVersion,precision:u,batching:me,batchingColor:me&&k._colorsTexture!==null,instancing:Pe,instancingColor:Pe&&k.instanceColor!==null,instancingMorph:Pe&&k.morphTexture!==null,outputColorSpace:j===null?i.outputColorSpace:j.isXRRenderTarget===!0?j.texture.colorSpace:Fe.workingColorSpace,alphaToCoverage:!!_.alphaToCoverage,map:Be,matcap:yt,envMap:Ve,envMapMode:Ve&&ne.mapping,envMapCubeUVHeight:X,aoMap:Ye,lightMap:rt,bumpMap:We,normalMap:lt,displacementMap:Et,emissiveMap:Ht,normalMapObjectSpace:lt&&_.normalMapType===mu,normalMapTangentSpace:lt&&_.normalMapType===Ar,packedNormalMap:lt&&_.normalMapType===Ar&&JM(_.normalMap.format),metalnessMap:ht,roughnessMap:Mt,anisotropy:I,anisotropyMap:W,clearcoat:zt,clearcoatMap:ie,clearcoatNormalMap:se,clearcoatRoughnessMap:Y,dispersion:je,retroreflection:w,iridescence:M,iridescenceMap:$,iridescenceThicknessMap:re,sheen:D,sheenColorMap:Se,sheenRoughnessMap:le,specularMap:ae,specularColorMap:we,specularIntensityMap:Re,transmission:B,transmissionMap:Le,thicknessMap:z,gradientMap:oe,opaque:_.transparent===!1&&_.blending===Es&&_.alphaToCoverage===!1,alphaMap:J,alphaTest:ce,alphaHash:de,combine:_.combine,mapUv:Be&&g(_.map.channel),aoMapUv:Ye&&g(_.aoMap.channel),lightMapUv:rt&&g(_.lightMap.channel),bumpMapUv:We&&g(_.bumpMap.channel),normalMapUv:lt&&g(_.normalMap.channel),displacementMapUv:Et&&g(_.displacementMap.channel),emissiveMapUv:Ht&&g(_.emissiveMap.channel),metalnessMapUv:ht&&g(_.metalnessMap.channel),roughnessMapUv:Mt&&g(_.roughnessMap.channel),anisotropyMapUv:W&&g(_.anisotropyMap.channel),clearcoatMapUv:ie&&g(_.clearcoatMap.channel),clearcoatNormalMapUv:se&&g(_.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:Y&&g(_.clearcoatRoughnessMap.channel),iridescenceMapUv:$&&g(_.iridescenceMap.channel),iridescenceThicknessMapUv:re&&g(_.iridescenceThicknessMap.channel),sheenColorMapUv:Se&&g(_.sheenColorMap.channel),sheenRoughnessMapUv:le&&g(_.sheenRoughnessMap.channel),specularMapUv:ae&&g(_.specularMap.channel),specularColorMapUv:we&&g(_.specularColorMap.channel),specularIntensityMapUv:Re&&g(_.specularIntensityMap.channel),transmissionMapUv:Le&&g(_.transmissionMap.channel),thicknessMapUv:z&&g(_.thicknessMap.channel),alphaMapUv:J&&g(_.alphaMap.channel),vertexTangents:!!V.attributes.tangent&&(lt||I),vertexNormals:!!V.attributes.normal,vertexColors:_.vertexColors,vertexAlphas:_.vertexColors===!0&&!!V.attributes.color&&V.attributes.color.itemSize===4,pointsUvs:k.isPoints===!0&&!!V.attributes.uv&&(Be||J),fog:!!L,useFog:_.fog===!0,fogExp2:!!L&&L.isFogExp2,flatShading:_.wireframe===!1&&(_.flatShading===!0||V.attributes.normal===void 0&&lt===!1&&(_.isMeshLambertMaterial||_.isMeshPhongMaterial||_.isMeshStandardMaterial||_.isMeshPhysicalMaterial)),sizeAttenuation:_.sizeAttenuation===!0,logarithmicDepthBuffer:f,reversedDepthBuffer:ge,skinning:k.isSkinnedMesh===!0,hasPositionAttribute:V.attributes.position!==void 0,morphTargets:V.morphAttributes.position!==void 0,morphNormals:V.morphAttributes.normal!==void 0,morphColors:V.morphAttributes.color!==void 0,morphTargetsCount:Ae,morphTextureStride:Te,numSunLights:E.sun.length,numDirLights:E.directional.length,numPointLights:E.point.length,numSpotLights:E.spot.length,numSpotLightMaps:E.spotLightMap.length,numRectAreaLights:E.rectArea.length,numHemiLights:E.hemi.length,numSunLightShadows:E.sunShadowMap.length,numDirLightShadows:E.directionalShadowMap.length,numPointLightShadows:E.pointShadowMap.length,numSpotLightShadows:E.spotShadowMap.length,numSpotLightShadowsWithMaps:E.numSpotLightShadowsWithMaps,numLightProbes:E.numLightProbes,numLightProbeGrids:H.length,numClippingPlanes:r.numPlanes,numClipIntersection:r.numIntersection,dithering:_.dithering,shadowMapEnabled:i.shadowMap.enabled&&P.length>0,shadowMapType:i.shadowMap.type,toneMapping:Ee,decodeVideoTexture:Be&&_.map.isVideoTexture===!0&&Fe.getTransfer(_.map.colorSpace)===$e,decodeVideoTextureEmissive:Ht&&_.emissiveMap.isVideoTexture===!0&&Fe.getTransfer(_.emissiveMap.colorSpace)===$e,premultipliedAlpha:_.premultipliedAlpha,doubleSided:_.side===hn,flipSided:_.side===Gt,useDepthPacking:_.depthPacking>=0,depthPacking:_.depthPacking||0,index0AttributeName:_.index0AttributeName,extensionClipCullDistance:ee&&_.extensions.clipCullDistance===!0&&t.has("WEBGL_clip_cull_distance"),extensionMultiDraw:(ee&&_.extensions.multiDraw===!0||me)&&t.has("WEBGL_multi_draw"),rendererExtensionParallelShaderCompile:t.has("KHR_parallel_shader_compile"),customProgramCacheKey:_.customProgramCacheKey()};return ye.vertexUv1s=c.has(1),ye.vertexUv2s=c.has(2),ye.vertexUv3s=c.has(3),c.clear(),ye}function m(_){let E=[];if(_.shaderID?E.push(_.shaderID):(E.push(_.customVertexShaderID),E.push(_.customFragmentShaderID)),_.defines!==void 0)for(let P in _.defines)E.push(P),E.push(_.defines[P]);return _.isRawShaderMaterial===!1&&(p(E,_),T(E,_),E.push(i.outputColorSpace)),E.push(_.customProgramCacheKey),E.join()}function p(_,E){_.push(E.precision),_.push(E.outputColorSpace),_.push(E.envMapMode),_.push(E.envMapCubeUVHeight),_.push(E.mapUv),_.push(E.alphaMapUv),_.push(E.lightMapUv),_.push(E.aoMapUv),_.push(E.bumpMapUv),_.push(E.normalMapUv),_.push(E.displacementMapUv),_.push(E.emissiveMapUv),_.push(E.metalnessMapUv),_.push(E.roughnessMapUv),_.push(E.anisotropyMapUv),_.push(E.clearcoatMapUv),_.push(E.clearcoatNormalMapUv),_.push(E.clearcoatRoughnessMapUv),_.push(E.iridescenceMapUv),_.push(E.iridescenceThicknessMapUv),_.push(E.sheenColorMapUv),_.push(E.sheenRoughnessMapUv),_.push(E.specularMapUv),_.push(E.specularColorMapUv),_.push(E.specularIntensityMapUv),_.push(E.transmissionMapUv),_.push(E.thicknessMapUv),_.push(E.combine),_.push(E.fogExp2),_.push(E.sizeAttenuation),_.push(E.morphTargetsCount),_.push(E.morphAttributeCount),_.push(E.numSunLights),_.push(E.numDirLights),_.push(E.numPointLights),_.push(E.numSpotLights),_.push(E.numSpotLightMaps),_.push(E.numHemiLights),_.push(E.numRectAreaLights),_.push(E.numSunLightShadows),_.push(E.numDirLightShadows),_.push(E.numPointLightShadows),_.push(E.numSpotLightShadows),_.push(E.numSpotLightShadowsWithMaps),_.push(E.numLightProbes),_.push(E.shadowMapType),_.push(E.toneMapping),_.push(E.numClippingPlanes),_.push(E.numClipIntersection),_.push(E.depthPacking)}function T(_,E){a.disableAll(),E.instancing&&a.enable(0),E.instancingColor&&a.enable(1),E.instancingMorph&&a.enable(2),E.matcap&&a.enable(3),E.envMap&&a.enable(4),E.normalMapObjectSpace&&a.enable(5),E.normalMapTangentSpace&&a.enable(6),E.clearcoat&&a.enable(7),E.iridescence&&a.enable(8),E.alphaTest&&a.enable(9),E.vertexColors&&a.enable(10),E.vertexAlphas&&a.enable(11),E.vertexUv1s&&a.enable(12),E.vertexUv2s&&a.enable(13),E.vertexUv3s&&a.enable(14),E.vertexTangents&&a.enable(15),E.anisotropy&&a.enable(16),E.alphaHash&&a.enable(17),E.batching&&a.enable(18),E.dispersion&&a.enable(19),E.retroreflection&&a.enable(24),E.batchingColor&&a.enable(20),E.gradientMap&&a.enable(21),E.packedNormalMap&&a.enable(22),E.vertexNormals&&a.enable(23),_.push(a.mask),a.disableAll(),E.fog&&a.enable(0),E.useFog&&a.enable(1),E.flatShading&&a.enable(2),E.logarithmicDepthBuffer&&a.enable(3),E.reversedDepthBuffer&&a.enable(4),E.skinning&&a.enable(5),E.morphTargets&&a.enable(6),E.morphNormals&&a.enable(7),E.morphColors&&a.enable(8),E.premultipliedAlpha&&a.enable(9),E.shadowMapEnabled&&a.enable(10),E.doubleSided&&a.enable(11),E.flipSided&&a.enable(12),E.useDepthPacking&&a.enable(13),E.dithering&&a.enable(14),E.transmission&&a.enable(15),E.sheen&&a.enable(16),E.opaque&&a.enable(17),E.pointsUvs&&a.enable(18),E.decodeVideoTexture&&a.enable(19),E.decodeVideoTextureEmissive&&a.enable(20),E.alphaToCoverage&&a.enable(21),E.numLightProbeGrids>0&&a.enable(22),E.hasPositionAttribute&&a.enable(23),_.push(a.mask)}function R(_){let E=d[_.type],P;if(E){let N=Bn[E];P=Ru.clone(N.uniforms)}else P=_.uniforms;return P}function v(_,E){let P=h.get(E);return P!==void 0?++P.usedTimes:(P=new ZM(i,E,_,s),l.push(P),h.set(E,P)),P}function b(_){if(--_.usedTimes===0){let E=l.indexOf(_);l[E]=l[l.length-1],l.pop(),h.delete(_.cacheKey),_.destroy()}}function S(_){o.remove(_)}function A(){o.dispose()}return{getParameters:y,getProgramCacheKey:m,getUniforms:R,acquireProgram:v,releaseProgram:b,releaseShaderCache:S,programs:l,dispose:A}}function jM(){let i=new WeakMap;function e(a){return i.has(a)}function t(a){let o=i.get(a);return o===void 0&&(o={},i.set(a,o)),o}function n(a){i.delete(a)}function s(a,o,c){i.get(a)[o]=c}function r(){i=new WeakMap}return{has:e,get:t,remove:n,update:s,dispose:r}}function QM(i,e){return i.groupOrder!==e.groupOrder?i.groupOrder-e.groupOrder:i.renderOrder!==e.renderOrder?i.renderOrder-e.renderOrder:i.material.id!==e.material.id?i.material.id-e.material.id:i.materialVariant!==e.materialVariant?i.materialVariant-e.materialVariant:i.z!==e.z?i.z-e.z:i.id-e.id}function Zu(i,e){return i.groupOrder!==e.groupOrder?i.groupOrder-e.groupOrder:i.renderOrder!==e.renderOrder?i.renderOrder-e.renderOrder:i.z!==e.z?e.z-i.z:i.id-e.id}function Ku(){let i=[],e=0,t=[],n=[],s=[];function r(){e=0,t.length=0,n.length=0,s.length=0}function a(u){let d=0;return u.isInstancedMesh&&(d+=2),u.isSkinnedMesh&&(d+=1),d}function o(u,d,g,y,m,p){let T=i[e];return T===void 0?(T={id:u.id,object:u,geometry:d,material:g,materialVariant:a(u),groupOrder:y,renderOrder:u.renderOrder,z:m,group:p},i[e]=T):(T.id=u.id,T.object=u,T.geometry=d,T.material=g,T.materialVariant=a(u),T.groupOrder=y,T.renderOrder=u.renderOrder,T.z=m,T.group=p),e++,T}function c(u,d,g,y,m,p,T){T.reversedDepth===!0&&(m=-m);let R=o(u,d,g,y,m,p);g.transmission>0?n.push(R):g.transparent===!0?s.push(R):t.push(R)}function l(u,d,g,y,m,p){let T=o(u,d,g,y,m,p);g.transmission>0?n.unshift(T):g.transparent===!0?s.unshift(T):t.unshift(T)}function h(u,d){t.length>1&&t.sort(u||QM),n.length>1&&n.sort(d||Zu),s.length>1&&s.sort(d||Zu)}function f(){for(let u=e,d=i.length;u<d;u++){let g=i[u];if(g.id===null)break;g.id=null,g.object=null,g.geometry=null,g.material=null,g.group=null}}return{opaque:t,transmissive:n,transparent:s,init:r,push:c,unshift:l,finish:f,sort:h}}function eg(){let i=new WeakMap;function e(n,s){let r=i.get(n),a;return r===void 0?(a=new Ku,i.set(n,[a])):s>=r.length?(a=new Ku,r.push(a)):a=r[s],a}function t(){i=new WeakMap}return{get:e,dispose:t}}function tg(){let i={};return{get:function(e){if(i[e.id]!==void 0)return i[e.id];let t;switch(e.type){case"SunLight":case"DirectionalLight":t={direction:new O,color:new Ce};break;case"SpotLight":t={position:new O,direction:new O,color:new Ce,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":t={position:new O,color:new Ce,distance:0,decay:0};break;case"HemisphereLight":t={direction:new O,skyColor:new Ce,groundColor:new Ce};break;case"RectAreaLight":t={color:new Ce,position:new O,halfWidth:new O,halfHeight:new O};break}return i[e.id]=t,t}}}function ng(){let i={};return{get:function(e){if(i[e.id]!==void 0)return i[e.id];let t;switch(e.type){case"SunLight":case"DirectionalLight":t={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Oe};break;case"SpotLight":t={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Oe};break;case"PointLight":t={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Oe,shadowCameraNear:1,shadowCameraFar:1e3};break}return i[e.id]=t,t}}}var ig=0;function sg(i,e){return(e.castShadow?2:0)-(i.castShadow?2:0)+(e.map?1:0)-(i.map?1:0)}function rg(i){let e=new tg,t=ng(),n={version:0,hash:{sunLength:-1,directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numSunShadows:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],sun:[],sunShadow:[],sunShadowMap:[],sunShadowMatrix:[],sunShadowCascade:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let l=0;l<9;l++)n.probe.push(new O);let s=new O,r=new Ne,a=new Ne;function o(l){let h=0,f=0,u=0;for(let k=0;k<9;k++)n.probe[k].set(0,0,0);let d=0,g=0,y=0,m=0,p=0,T=0,R=0,v=0,b=0,S=0,A=0,_=0,E=0,P=0;l.sort(sg);for(let k=0,H=l.length;k<H;k++){let L=l[k],V=L.color,K=L.intensity,Z=L.distance,ne=null;if(L.shadow&&L.shadow.map&&(L.shadow.map.texture.format===xi?ne=L.shadow.map.texture:ne=L.shadow.map.depthTexture||L.shadow.map.texture),L.isAmbientLight)h+=V.r*K,f+=V.g*K,u+=V.b*K;else if(L.isLightProbe){for(let X=0;X<9;X++)n.probe[X].addScaledVector(L.sh.coefficients[X],K);P++}else if(L.isSunLight){let X=e.get(L);if(X.color.copy(L.color).multiplyScalar(L.intensity),L.castShadow){let Q=L.shadow,te=t.get(L);te.shadowIntensity=Q.intensity,te.shadowBias=Q.bias,te.shadowNormalBias=Q.normalBias,te.shadowRadius=Q.radius,te.shadowMapSize.copy(Q.mapSize).multiply(Q.getFrameExtents()),n.sunShadow[g]=te,n.sunShadowMap[g]=ne;let Ae=Q.getViewportCount();for(let Te=0;Te<Ae;Te++)n.sunShadowMatrix[y+Te]=Q.getMatrix(Te),n.sunShadowCascade[y+Te]=Q._cascadeData[Te];y+=Ae,g++}n.sun[d]=X,d++}else if(L.isDirectionalLight){let X=e.get(L);if(X.color.copy(L.color).multiplyScalar(L.intensity),L.castShadow){let Q=L.shadow,te=t.get(L);te.shadowIntensity=Q.intensity,te.shadowBias=Q.bias,te.shadowNormalBias=Q.normalBias,te.shadowRadius=Q.radius,te.shadowMapSize=Q.mapSize,n.directionalShadow[m]=te,n.directionalShadowMap[m]=ne,n.directionalShadowMatrix[m]=L.shadow.matrix,b++}n.directional[m]=X,m++}else if(L.isSpotLight){let X=e.get(L);X.position.setFromMatrixPosition(L.matrixWorld),X.color.copy(V).multiplyScalar(K),X.distance=Z,X.coneCos=Math.cos(L.angle),X.penumbraCos=Math.cos(L.angle*(1-L.penumbra)),X.decay=L.decay,n.spot[T]=X;let Q=L.shadow;if(L.map&&(n.spotLightMap[_]=L.map,_++,Q.updateMatrices(L),L.castShadow&&E++),n.spotLightMatrix[T]=Q.matrix,L.castShadow){let te=t.get(L);te.shadowIntensity=Q.intensity,te.shadowBias=Q.bias,te.shadowNormalBias=Q.normalBias,te.shadowRadius=Q.radius,te.shadowMapSize=Q.mapSize,n.spotShadow[T]=te,n.spotShadowMap[T]=ne,A++}T++}else if(L.isRectAreaLight){let X=e.get(L);X.color.copy(V).multiplyScalar(K),X.halfWidth.set(L.width*.5,0,0),X.halfHeight.set(0,L.height*.5,0),n.rectArea[R]=X,R++}else if(L.isPointLight){let X=e.get(L);if(X.color.copy(L.color).multiplyScalar(L.intensity),X.distance=L.distance,X.decay=L.decay,L.castShadow){let Q=L.shadow,te=t.get(L);te.shadowIntensity=Q.intensity,te.shadowBias=Q.bias,te.shadowNormalBias=Q.normalBias,te.shadowRadius=Q.radius,te.shadowMapSize=Q.mapSize,te.shadowCameraNear=Q.camera.near,te.shadowCameraFar=Q.camera.far,n.pointShadow[p]=te,n.pointShadowMap[p]=ne,n.pointShadowMatrix[p]=L.shadow.matrix,S++}n.point[p]=X,p++}else if(L.isHemisphereLight){let X=e.get(L);X.skyColor.copy(L.color).multiplyScalar(K),X.groundColor.copy(L.groundColor).multiplyScalar(K),n.hemi[v]=X,v++}}R>0&&(i.has("OES_texture_float_linear")===!0?(n.rectAreaLTC1=he.LTC_FLOAT_1,n.rectAreaLTC2=he.LTC_FLOAT_2):(n.rectAreaLTC1=he.LTC_HALF_1,n.rectAreaLTC2=he.LTC_HALF_2)),n.ambient[0]=h,n.ambient[1]=f,n.ambient[2]=u;let N=n.hash;(N.sunLength!==d||N.directionalLength!==m||N.pointLength!==p||N.spotLength!==T||N.rectAreaLength!==R||N.hemiLength!==v||N.numSunShadows!==g||N.numDirectionalShadows!==b||N.numPointShadows!==S||N.numSpotShadows!==A||N.numSpotMaps!==_||N.numLightProbes!==P)&&(n.sun.length=d,n.directional.length=m,n.spot.length=T,n.rectArea.length=R,n.point.length=p,n.hemi.length=v,n.sunShadow.length=g,n.sunShadowMap.length=g,n.sunShadowMatrix.length=y,n.sunShadowCascade.length=y,n.directionalShadow.length=b,n.directionalShadowMap.length=b,n.directionalShadowMatrix.length=b,n.pointShadow.length=S,n.pointShadowMap.length=S,n.pointShadowMatrix.length=S,n.spotShadow.length=A,n.spotShadowMap.length=A,n.spotLightMatrix.length=A+_-E,n.spotLightMap.length=_,n.numSpotLightShadowsWithMaps=E,n.numLightProbes=P,N.sunLength=d,N.directionalLength=m,N.pointLength=p,N.spotLength=T,N.rectAreaLength=R,N.hemiLength=v,N.numSunShadows=g,N.numDirectionalShadows=b,N.numPointShadows=S,N.numSpotShadows=A,N.numSpotMaps=_,N.numLightProbes=P,n.version=ig++)}function c(l,h){let f=0,u=0,d=0,g=0,y=0,m=0,p=h.matrixWorldInverse;for(let T=0,R=l.length;T<R;T++){let v=l[T];if(v.isSunLight){let b=n.sun[f];b.direction.setFromMatrixPosition(v.matrixWorld),b.direction.transformDirection(p),f++}else if(v.isDirectionalLight){let b=n.directional[u];b.direction.setFromMatrixPosition(v.matrixWorld),s.setFromMatrixPosition(v.target.matrixWorld),b.direction.sub(s),b.direction.transformDirection(p),u++}else if(v.isSpotLight){let b=n.spot[g];b.position.setFromMatrixPosition(v.matrixWorld),b.position.applyMatrix4(p),b.direction.setFromMatrixPosition(v.matrixWorld),s.setFromMatrixPosition(v.target.matrixWorld),b.direction.sub(s),b.direction.transformDirection(p),g++}else if(v.isRectAreaLight){let b=n.rectArea[y];b.position.setFromMatrixPosition(v.matrixWorld),b.position.applyMatrix4(p),a.identity(),r.copy(v.matrixWorld),r.premultiply(p),a.extractRotation(r),b.halfWidth.set(v.width*.5,0,0),b.halfHeight.set(0,v.height*.5,0),b.halfWidth.applyMatrix4(a),b.halfHeight.applyMatrix4(a),y++}else if(v.isPointLight){let b=n.point[d];b.position.setFromMatrixPosition(v.matrixWorld),b.position.applyMatrix4(p),d++}else if(v.isHemisphereLight){let b=n.hemi[m];b.direction.setFromMatrixPosition(v.matrixWorld),b.direction.transformDirection(p),m++}}}return{setup:o,setupView:c,state:n}}function Ju(i){let e=new rg(i),t=[],n=[],s=[];function r(u){f.camera=u,t.length=0,n.length=0,s.length=0}function a(u){t.push(u)}function o(u){n.push(u)}function c(u){s.push(u)}function l(){e.setup(t)}function h(u){e.setupView(t,u)}let f={lightsArray:t,shadowsArray:n,lightProbeGridArray:s,camera:null,lights:e,transmissionRenderTarget:{},textureUnits:0};return{init:r,state:f,setupLights:l,setupLightsView:h,pushLight:a,pushShadow:o,pushLightProbeGrid:c}}function ag(i){let e=new WeakMap;function t(s,r=0){let a=e.get(s),o;return a===void 0?(o=new Ju(i),e.set(s,[o])):r>=a.length?(o=new Ju(i),a.push(o)):o=a[r],o}function n(){e=new WeakMap}return{get:t,dispose:n}}var og=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,cg=`uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;
void main() {
	const float samples = float( VSM_SAMPLES );
	float mean = 0.0;
	float squared_mean = 0.0;
	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {
		float uvOffset = uvStart + i * uvStride;
		#ifdef HORIZONTAL_PASS
			vec2 distribution = texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ).rg;
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
		#else
			float depth = texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ).r;
			mean += depth;
			squared_mean += depth * depth;
		#endif
	}
	mean = mean / samples;
	squared_mean = squared_mean / samples;
	float std_dev = sqrt( max( 0.0, squared_mean - mean * mean ) );
	gl_FragColor = vec4( mean, std_dev, 0.0, 1.0 );
}`,lg=[new O(1,0,0),new O(-1,0,0),new O(0,1,0),new O(0,-1,0),new O(0,0,1),new O(0,0,-1)],hg=[new O(0,-1,0),new O(0,-1,0),new O(0,0,1),new O(0,0,-1),new O(0,-1,0),new O(0,-1,0)],$u=new Ne,Cr=new O,ol=new O;function ug(i,e,t){let n=new xs,s=new Oe,r=new Oe,a=new et,o=new wa,c=new Ta,l={},h=t.maxTextureSize,f={[On]:Gt,[Gt]:On,[hn]:hn},u=new tn({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new Oe},radius:{value:4}},vertexShader:og,fragmentShader:cg}),d=u.clone();d.defines.HORIZONTAL_PASS=1;let g=new Nt;g.setAttribute("position",new bt(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));let y=new Ct(g,u),m=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=_r;let p=this.type;this.render=function(S,A,_){if(m.enabled===!1||m.autoUpdate===!1&&m.needsUpdate===!1||S.length===0)return;this.type===Xh&&(be("WebGLShadowMap: PCFSoftShadowMap has been removed. Using PCFShadowMap instead."),this.type=_r);let E=i.getRenderTarget(),P=i.getActiveCubeFace(),N=i.getActiveMipmapLevel(),k=i.state;k.setBlending(Un),k.buffers.depth.getReversed()===!0?k.buffers.color.setClear(0,0,0,0):k.buffers.color.setClear(1,1,1,1),k.buffers.depth.setTest(!0),k.setScissorTest(!1);let H=p!==this.type;H&&A.traverse(function(L){L.material&&(Array.isArray(L.material)?L.material.forEach(V=>V.needsUpdate=!0):L.material.needsUpdate=!0)});for(let L=0,V=S.length;L<V;L++){let K=S[L],Z=K.shadow;if(Z===void 0){be("WebGLShadowMap:",K,"has no shadow.");continue}if(Z.autoUpdate===!1&&Z.needsUpdate===!1)continue;s.copy(Z.mapSize);let ne=Z.getFrameExtents();s.multiply(ne),r.copy(Z.mapSize),(s.x>h||s.y>h)&&(s.x>h&&(r.x=Math.floor(h/ne.x),s.x=r.x*ne.x,Z.mapSize.x=r.x),s.y>h&&(r.y=Math.floor(h/ne.y),s.y=r.y*ne.y,Z.mapSize.y=r.y));let X=i.state.buffers.depth.getReversed();if(Z.camera._reversedDepth=X,Z.map===null||H===!0){if(Z.map!==null&&(Z.map.depthTexture!==null&&(Z.map.depthTexture.dispose(),Z.map.depthTexture=null),Z.map.dispose()),this.type===Ts){if(K.isPointLight){be("WebGLShadowMap: VSM shadow maps are not supported for PointLights. Use PCF or BasicShadowMap instead.");continue}Z.map=new Wt(s.x,s.y,{format:xi,type:wn,minFilter:pt,magFilter:pt,generateMipmaps:!1}),Z.map.texture.name=K.name+".shadowMap",Z.map.depthTexture=new pi(s.x,s.y,nn),Z.map.depthTexture.name=K.name+".shadowMapDepth",Z.map.depthTexture.format=In,Z.map.depthTexture.compareFunction=null,Z.map.depthTexture.minFilter=dt,Z.map.depthTexture.magFilter=dt}else K.isPointLight?(Z.map=new Ro(s.x),Z.map.depthTexture=new ba(s.x,Sn)):(Z.map=new Wt(s.x,s.y),Z.map.depthTexture=new pi(s.x,s.y,Sn)),Z.map.depthTexture.name=K.name+".shadowMap",Z.map.depthTexture.format=In,this.type===_r?(Z.map.depthTexture.compareFunction=X?wo:So,Z.map.depthTexture.minFilter=pt,Z.map.depthTexture.magFilter=pt):(Z.map.depthTexture.compareFunction=null,Z.map.depthTexture.minFilter=dt,Z.map.depthTexture.magFilter=dt);Z.camera.updateProjectionMatrix()}Z.map.isWebGLCubeRenderTarget!==!0&&(Z.map.width!==s.x||Z.map.height!==s.y)&&Z.map.setSize(s.x,s.y);let Q=Z.map.isWebGLCubeRenderTarget?6:Z.getViewportCount();K.isPointLight!==!0&&Z.updateMatrices(K,_);for(let te=0;te<Q;te++){let Ae=Z.getCamera(te);if(K.isPointLight){let Te=Z.camera,st=Z.matrix,Xe=K.distance||Te.far;Xe!==Te.far&&(Te.far=Xe,Te.updateProjectionMatrix()),Cr.setFromMatrixPosition(K.matrixWorld),Te.position.copy(Cr),ol.copy(Te.position),ol.add(lg[te]),Te.up.copy(hg[te]),Te.lookAt(ol),Te.updateMatrixWorld(),st.makeTranslation(-Cr.x,-Cr.y,-Cr.z),$u.multiplyMatrices(Te.projectionMatrix,Te.matrixWorldInverse),Z._frustum.setFromProjectionMatrix($u,Te.coordinateSystem,Te.reversedDepth)}if(Z.map.isWebGLCubeRenderTarget)i.setRenderTarget(Z.map,te),i.clear();else{te===0&&(i.setRenderTarget(Z.map),i.clear());let Te=Z.getViewport(te);a.set(r.x*Te.x,r.y*Te.y,r.x*Te.z,r.y*Te.w),k.viewport(a)}n=Z.getFrustum(te),v(A,_,Ae,K,this.type)}Z.isPointLightShadow!==!0&&this.type===Ts&&T(Z,_),Z.needsUpdate=!1}p=this.type,m.needsUpdate=!1,i.setRenderTarget(E,P,N)};function T(S,A){let _=e.update(y);u.defines.VSM_SAMPLES!==S.blurSamples&&(u.defines.VSM_SAMPLES=S.blurSamples,d.defines.VSM_SAMPLES=S.blurSamples,u.needsUpdate=!0,d.needsUpdate=!0),S.mapPass===null?S.mapPass=new Wt(s.x,s.y,{format:xi,type:wn}):(S.mapPass.width!==S.map.width||S.mapPass.height!==S.map.height)&&S.mapPass.setSize(S.map.width,S.map.height),u.uniforms.shadow_pass.value=S.map.depthTexture,u.uniforms.resolution.value.set(S.map.width,S.map.height),u.uniforms.radius.value=S.radius,i.setRenderTarget(S.mapPass),i.clear(),i.renderBufferDirect(A,null,_,u,y,null),d.uniforms.shadow_pass.value=S.mapPass.texture,d.uniforms.resolution.value.set(S.map.width,S.map.height),d.uniforms.radius.value=S.radius,i.setRenderTarget(S.map),i.clear(),i.renderBufferDirect(A,null,_,d,y,null)}function R(S,A,_,E){let P=null,N=_.isPointLight===!0?S.customDistanceMaterial:S.customDepthMaterial;if(N!==void 0)P=N;else if(P=_.isPointLight===!0?c:o,i.localClippingEnabled&&A.clipShadows===!0&&Array.isArray(A.clippingPlanes)&&A.clippingPlanes.length!==0||A.displacementMap&&A.displacementScale!==0||A.alphaMap&&A.alphaTest>0||A.map&&A.alphaTest>0||A.alphaToCoverage===!0){let k=P.uuid,H=A.uuid,L=l[k];L===void 0&&(L={},l[k]=L);let V=L[H];V===void 0&&(V=P.clone(),L[H]=V,A.addEventListener("dispose",b)),P=V}if(P.visible=A.visible,P.wireframe=A.wireframe,E===Ts?P.side=A.shadowSide!==null?A.shadowSide:A.side:P.side=A.shadowSide!==null?A.shadowSide:f[A.side],P.alphaMap=A.alphaMap,P.alphaTest=A.alphaToCoverage===!0?.5:A.alphaTest,P.map=A.map,P.clipShadows=A.clipShadows,P.clippingPlanes=A.clippingPlanes,P.clipIntersection=A.clipIntersection,P.displacementMap=A.displacementMap,P.displacementScale=A.displacementScale,P.displacementBias=A.displacementBias,P.wireframeLinewidth=A.wireframeLinewidth,P.linewidth=A.linewidth,_.isPointLight===!0&&P.isMeshDistanceMaterial===!0){let k=i.properties.get(P);k.light=_}return P}function v(S,A,_,E,P){if(S.visible===!1)return;if(S.layers.test(A.layers)&&(S.isMesh||S.isLine||S.isPoints)&&(S.castShadow||S.receiveShadow&&P===Ts)&&(!S.frustumCulled||S.intersectsFrustum(n))){S.modelViewMatrix.multiplyMatrices(_.matrixWorldInverse,S.matrixWorld);let H=e.update(S),L=S.material;if(Array.isArray(L)){let V=H.groups;for(let K=0,Z=V.length;K<Z;K++){let ne=V[K],X=L[ne.materialIndex];if(X&&X.visible){let Q=R(S,X,E,P);S.onBeforeShadow(i,S,A,_,H,Q,ne),i.renderBufferDirect(_,null,H,Q,S,ne),S.onAfterShadow(i,S,A,_,H,Q,ne)}}}else if(L.visible){let V=R(S,L,E,P);S.onBeforeShadow(i,S,A,_,H,V,null),i.renderBufferDirect(_,null,H,V,S,null),S.onAfterShadow(i,S,A,_,H,V,null)}}let k=S.children;for(let H=0,L=k.length;H<L;H++)v(k[H],A,_,E,P)}function b(S){S.target.removeEventListener("dispose",b);for(let _ in l){let E=l[_],P=S.target.uuid;P in E&&(E[P].dispose(),delete E[P])}}}function fg(i,e){function t(){let z=!1,oe=new et,J=null,ce=new et(0,0,0,0);return{setMask:function(de){J!==de&&!z&&(i.colorMask(de,de,de,de),J=de)},setLocked:function(de){z=de},setClear:function(de,ee,Ee,ye,at){at===!0&&(de*=ye,ee*=ye,Ee*=ye),oe.set(de,ee,Ee,ye),ce.equals(oe)===!1&&(i.clearColor(de,ee,Ee,ye),ce.copy(oe))},reset:function(){z=!1,J=null,ce.set(-1,0,0,0)}}}function n(){let z=!1,oe=!1,J=null,ce=null,de=null;return{setReversed:function(ee){if(oe!==ee){let Ee=e.get("EXT_clip_control");ee?Ee.clipControlEXT(Ee.LOWER_LEFT_EXT,Ee.ZERO_TO_ONE_EXT):Ee.clipControlEXT(Ee.LOWER_LEFT_EXT,Ee.NEGATIVE_ONE_TO_ONE_EXT),oe=ee;let ye=de;de=null,this.setClear(ye)}},getReversed:function(){return oe},setTest:function(ee){ee?j(i.DEPTH_TEST):ge(i.DEPTH_TEST)},setMask:function(ee){J!==ee&&!z&&(i.depthMask(ee),J=ee)},setFunc:function(ee){if(oe&&(ee=Eu[ee]),ce!==ee){switch(ee){case ha:i.depthFunc(i.NEVER);break;case ua:i.depthFunc(i.ALWAYS);break;case fa:i.depthFunc(i.LESS);break;case cs:i.depthFunc(i.LEQUAL);break;case da:i.depthFunc(i.EQUAL);break;case pa:i.depthFunc(i.GEQUAL);break;case ma:i.depthFunc(i.GREATER);break;case Ma:i.depthFunc(i.NOTEQUAL);break;default:i.depthFunc(i.LEQUAL)}ce=ee}},setLocked:function(ee){z=ee},setClear:function(ee){de!==ee&&(de=ee,oe&&(ee=1-ee),i.clearDepth(ee))},reset:function(){z=!1,J=null,ce=null,de=null,oe=!1}}}function s(){let z=!1,oe=null,J=null,ce=null,de=null,ee=null,Ee=null,ye=null,at=null;return{setTest:function(Ke){z||(Ke?j(i.STENCIL_TEST):ge(i.STENCIL_TEST))},setMask:function(Ke){oe!==Ke&&!z&&(i.stencilMask(Ke),oe=Ke)},setFunc:function(Ke,fn,An){(J!==Ke||ce!==fn||de!==An)&&(i.stencilFunc(Ke,fn,An),J=Ke,ce=fn,de=An)},setOp:function(Ke,fn,An){(ee!==Ke||Ee!==fn||ye!==An)&&(i.stencilOp(Ke,fn,An),ee=Ke,Ee=fn,ye=An)},setLocked:function(Ke){z=Ke},setClear:function(Ke){at!==Ke&&(i.clearStencil(Ke),at=Ke)},reset:function(){z=!1,oe=null,J=null,ce=null,de=null,ee=null,Ee=null,ye=null,at=null}}}let r=new t,a=new n,o=new s,c=new WeakMap,l=new WeakMap,h={},f={},u={},d=new WeakMap,g=[],y=null,m=!1,p=null,T=null,R=null,v=null,b=null,S=null,A=null,_=new Ce(0,0,0),E=0,P=!1,N=null,k=null,H=null,L=null,V=null,K=i.getParameter(i.MAX_COMBINED_TEXTURE_IMAGE_UNITS),Z=!1,ne=0,X=i.getParameter(i.VERSION);X.indexOf("WebGL")!==-1?(ne=parseFloat(/^WebGL (\d)/.exec(X)[1]),Z=ne>=1):X.indexOf("OpenGL ES")!==-1&&(ne=parseFloat(/^OpenGL ES (\d)/.exec(X)[1]),Z=ne>=2);let Q=null,te={},Ae=i.getParameter(i.SCISSOR_BOX),Te=i.getParameter(i.VIEWPORT),st=new et().fromArray(Ae),Xe=new et().fromArray(Te);function Ze(z,oe,J,ce){let de=new Uint8Array(4),ee=i.createTexture();i.bindTexture(z,ee),i.texParameteri(z,i.TEXTURE_MIN_FILTER,i.NEAREST),i.texParameteri(z,i.TEXTURE_MAG_FILTER,i.NEAREST);for(let Ee=0;Ee<J;Ee++)z===i.TEXTURE_3D||z===i.TEXTURE_2D_ARRAY?i.texImage3D(oe,0,i.RGBA,1,1,ce,0,i.RGBA,i.UNSIGNED_BYTE,de):i.texImage2D(oe+Ee,0,i.RGBA,1,1,0,i.RGBA,i.UNSIGNED_BYTE,de);return ee}let q={};q[i.TEXTURE_2D]=Ze(i.TEXTURE_2D,i.TEXTURE_2D,1),q[i.TEXTURE_CUBE_MAP]=Ze(i.TEXTURE_CUBE_MAP,i.TEXTURE_CUBE_MAP_POSITIVE_X,6),q[i.TEXTURE_2D_ARRAY]=Ze(i.TEXTURE_2D_ARRAY,i.TEXTURE_2D_ARRAY,1,1),q[i.TEXTURE_3D]=Ze(i.TEXTURE_3D,i.TEXTURE_3D,1,1),r.setClear(0,0,0,1),a.setClear(1),o.setClear(0),j(i.DEPTH_TEST),a.setFunc(cs),We(!1),lt(Rc),j(i.CULL_FACE),Ye(Un);function j(z){h[z]!==!0&&(i.enable(z),h[z]=!0)}function ge(z){h[z]!==!1&&(i.disable(z),h[z]=!1)}function Pe(z,oe){return u[z]!==oe?(i.bindFramebuffer(z,oe),u[z]=oe,z===i.DRAW_FRAMEBUFFER&&(u[i.FRAMEBUFFER]=oe),z===i.FRAMEBUFFER&&(u[i.DRAW_FRAMEBUFFER]=oe),!0):!1}function me(z,oe){let J=g,ce=!1;if(z){J=d.get(oe),J===void 0&&(J=[],d.set(oe,J));let de=z.textures;if(J.length!==de.length||J[0]!==i.COLOR_ATTACHMENT0){for(let ee=0,Ee=de.length;ee<Ee;ee++)J[ee]=i.COLOR_ATTACHMENT0+ee;J.length=de.length,ce=!0}}else J[0]!==i.BACK&&(J[0]=i.BACK,ce=!0);ce&&i.drawBuffers(J)}function Be(z){return y!==z?(i.useProgram(z),y=z,!0):!1}let yt={[Ui]:i.FUNC_ADD,[Yh]:i.FUNC_SUBTRACT,[Zh]:i.FUNC_REVERSE_SUBTRACT};yt[Kh]=i.MIN,yt[Jh]=i.MAX;let Ve={[$h]:i.ZERO,[jh]:i.ONE,[Qh]:i.SRC_COLOR,[Pc]:i.SRC_ALPHA,[ru]:i.SRC_ALPHA_SATURATE,[iu]:i.DST_COLOR,[tu]:i.DST_ALPHA,[eu]:i.ONE_MINUS_SRC_COLOR,[Lc]:i.ONE_MINUS_SRC_ALPHA,[su]:i.ONE_MINUS_DST_COLOR,[nu]:i.ONE_MINUS_DST_ALPHA,[au]:i.CONSTANT_COLOR,[ou]:i.ONE_MINUS_CONSTANT_COLOR,[cu]:i.CONSTANT_ALPHA,[lu]:i.ONE_MINUS_CONSTANT_ALPHA};function Ye(z,oe,J,ce,de,ee,Ee,ye,at,Ke){if(z===Un){m===!0&&(ge(i.BLEND),m=!1);return}if(m===!1&&(j(i.BLEND),m=!0),z!==qh){if(z!==p||Ke!==P){if((T!==Ui||b!==Ui)&&(i.blendEquation(i.FUNC_ADD),T=Ui,b=Ui),Ke)switch(z){case Es:i.blendFuncSeparate(i.ONE,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case Cc:i.blendFunc(i.ONE,i.ONE);break;case zc:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case Ic:i.blendFuncSeparate(i.DST_COLOR,i.ONE_MINUS_SRC_ALPHA,i.ZERO,i.ONE);break;default:ze("WebGLState: Invalid blending: ",z);break}else switch(z){case Es:i.blendFuncSeparate(i.SRC_ALPHA,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case Cc:i.blendFuncSeparate(i.SRC_ALPHA,i.ONE,i.ONE,i.ONE);break;case zc:ze("WebGLState: SubtractiveBlending requires material.premultipliedAlpha = true");break;case Ic:ze("WebGLState: MultiplyBlending requires material.premultipliedAlpha = true");break;default:ze("WebGLState: Invalid blending: ",z);break}R=null,v=null,S=null,A=null,_.set(0,0,0),E=0,p=z,P=Ke}return}de=de||oe,ee=ee||J,Ee=Ee||ce,(oe!==T||de!==b)&&(i.blendEquationSeparate(yt[oe],yt[de]),T=oe,b=de),(J!==R||ce!==v||ee!==S||Ee!==A)&&(i.blendFuncSeparate(Ve[J],Ve[ce],Ve[ee],Ve[Ee]),R=J,v=ce,S=ee,A=Ee),(ye.equals(_)===!1||at!==E)&&(i.blendColor(ye.r,ye.g,ye.b,at),_.copy(ye),E=at),p=z,P=!1}function rt(z,oe){z.side===hn?ge(i.CULL_FACE):j(i.CULL_FACE);let J=z.side===Gt;oe&&(J=!J),We(J),z.blending===Es&&z.transparent===!1?Ye(Un):Ye(z.blending,z.blendEquation,z.blendSrc,z.blendDst,z.blendEquationAlpha,z.blendSrcAlpha,z.blendDstAlpha,z.blendColor,z.blendAlpha,z.premultipliedAlpha),a.setFunc(z.depthFunc),a.setTest(z.depthTest),a.setMask(z.depthWrite),r.setMask(z.colorWrite);let ce=z.stencilWrite;o.setTest(ce),ce&&(o.setMask(z.stencilWriteMask),o.setFunc(z.stencilFunc,z.stencilRef,z.stencilFuncMask),o.setOp(z.stencilFail,z.stencilZFail,z.stencilZPass)),Ht(z.polygonOffset,z.polygonOffsetFactor,z.polygonOffsetUnits),z.alphaToCoverage===!0?j(i.SAMPLE_ALPHA_TO_COVERAGE):ge(i.SAMPLE_ALPHA_TO_COVERAGE)}function We(z){N!==z&&(z?i.frontFace(i.CW):i.frontFace(i.CCW),N=z)}function lt(z){z!==Hh?(j(i.CULL_FACE),z!==k&&(z===Rc?i.cullFace(i.BACK):z===Wh?i.cullFace(i.FRONT):i.cullFace(i.FRONT_AND_BACK))):ge(i.CULL_FACE),k=z}function Et(z){z!==H&&(Z&&i.lineWidth(z),H=z)}function Ht(z,oe,J){z?(j(i.POLYGON_OFFSET_FILL),(L!==oe||V!==J)&&(L=oe,V=J,a.getReversed()&&(oe=-oe),i.polygonOffset(oe,J))):ge(i.POLYGON_OFFSET_FILL)}function ht(z){z?j(i.SCISSOR_TEST):ge(i.SCISSOR_TEST)}function Mt(z){z===void 0&&(z=i.TEXTURE0+K-1),Q!==z&&(i.activeTexture(z),Q=z)}function I(z,oe,J){J===void 0&&(Q===null?J=i.TEXTURE0+K-1:J=Q);let ce=te[J];ce===void 0&&(ce={type:void 0,texture:void 0},te[J]=ce),(ce.type!==z||ce.texture!==oe)&&(Q!==J&&(i.activeTexture(J),Q=J),i.bindTexture(z,oe||q[z]),ce.type=z,ce.texture=oe)}function zt(){let z=te[Q];z!==void 0&&z.type!==void 0&&(i.bindTexture(z.type,null),z.type=void 0,z.texture=void 0)}function je(){try{i.compressedTexImage2D(...arguments)}catch(z){ze("WebGLState:",z)}}function w(){try{i.compressedTexImage3D(...arguments)}catch(z){ze("WebGLState:",z)}}function M(){try{i.texSubImage2D(...arguments)}catch(z){ze("WebGLState:",z)}}function D(){try{i.texSubImage3D(...arguments)}catch(z){ze("WebGLState:",z)}}function B(){try{i.compressedTexSubImage2D(...arguments)}catch(z){ze("WebGLState:",z)}}function W(){try{i.compressedTexSubImage3D(...arguments)}catch(z){ze("WebGLState:",z)}}function ie(){try{i.texStorage2D(...arguments)}catch(z){ze("WebGLState:",z)}}function se(){try{i.texStorage3D(...arguments)}catch(z){ze("WebGLState:",z)}}function Y(){try{i.texImage2D(...arguments)}catch(z){ze("WebGLState:",z)}}function $(){try{i.texImage3D(...arguments)}catch(z){ze("WebGLState:",z)}}function re(z){return f[z]!==void 0?f[z]:i.getParameter(z)}function Se(z,oe){f[z]!==oe&&(i.pixelStorei(z,oe),f[z]=oe)}function le(z){st.equals(z)===!1&&(i.scissor(z.x,z.y,z.z,z.w),st.copy(z))}function ae(z){Xe.equals(z)===!1&&(i.viewport(z.x,z.y,z.z,z.w),Xe.copy(z))}function we(z,oe){let J=l.get(oe);J===void 0&&(J=new WeakMap,l.set(oe,J));let ce=J.get(z);ce===void 0&&(ce=i.getUniformBlockIndex(oe,z.name),J.set(z,ce))}function Re(z,oe){let ce=l.get(oe).get(z);c.get(oe)!==ce&&(i.uniformBlockBinding(oe,ce,z.__bindingPointIndex),c.set(oe,ce))}function Le(){i.disable(i.BLEND),i.disable(i.CULL_FACE),i.disable(i.DEPTH_TEST),i.disable(i.POLYGON_OFFSET_FILL),i.disable(i.SCISSOR_TEST),i.disable(i.STENCIL_TEST),i.disable(i.SAMPLE_ALPHA_TO_COVERAGE),i.blendEquation(i.FUNC_ADD),i.blendFunc(i.ONE,i.ZERO),i.blendFuncSeparate(i.ONE,i.ZERO,i.ONE,i.ZERO),i.blendColor(0,0,0,0),i.colorMask(!0,!0,!0,!0),i.clearColor(0,0,0,0),i.depthMask(!0),i.depthFunc(i.LESS),a.setReversed(!1),i.clearDepth(1),i.stencilMask(4294967295),i.stencilFunc(i.ALWAYS,0,4294967295),i.stencilOp(i.KEEP,i.KEEP,i.KEEP),i.clearStencil(0),i.cullFace(i.BACK),i.frontFace(i.CCW),i.polygonOffset(0,0),i.activeTexture(i.TEXTURE0),i.bindFramebuffer(i.FRAMEBUFFER,null),i.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),i.bindFramebuffer(i.READ_FRAMEBUFFER,null),i.useProgram(null),i.lineWidth(1),i.scissor(0,0,i.canvas.width,i.canvas.height),i.viewport(0,0,i.canvas.width,i.canvas.height),i.pixelStorei(i.PACK_ALIGNMENT,4),i.pixelStorei(i.UNPACK_ALIGNMENT,4),i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,!1),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,!1),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,i.BROWSER_DEFAULT_WEBGL),i.pixelStorei(i.PACK_ROW_LENGTH,0),i.pixelStorei(i.PACK_SKIP_PIXELS,0),i.pixelStorei(i.PACK_SKIP_ROWS,0),i.pixelStorei(i.UNPACK_ROW_LENGTH,0),i.pixelStorei(i.UNPACK_IMAGE_HEIGHT,0),i.pixelStorei(i.UNPACK_SKIP_PIXELS,0),i.pixelStorei(i.UNPACK_SKIP_ROWS,0),i.pixelStorei(i.UNPACK_SKIP_IMAGES,0),h={},f={},Q=null,te={},u={},d=new WeakMap,g=[],y=null,m=!1,p=null,T=null,R=null,v=null,b=null,S=null,A=null,_=new Ce(0,0,0),E=0,P=!1,N=null,k=null,H=null,L=null,V=null,st.set(0,0,i.canvas.width,i.canvas.height),Xe.set(0,0,i.canvas.width,i.canvas.height),r.reset(),a.reset(),o.reset()}return{buffers:{color:r,depth:a,stencil:o},enable:j,disable:ge,bindFramebuffer:Pe,drawBuffers:me,useProgram:Be,setBlending:Ye,setMaterial:rt,setFlipSided:We,setCullFace:lt,setLineWidth:Et,setPolygonOffset:Ht,setScissorTest:ht,activeTexture:Mt,bindTexture:I,unbindTexture:zt,compressedTexImage2D:je,compressedTexImage3D:w,texImage2D:Y,texImage3D:$,pixelStorei:Se,getParameter:re,updateUBOMapping:we,uniformBlockBinding:Re,texStorage2D:ie,texStorage3D:se,texSubImage2D:M,texSubImage3D:D,compressedTexSubImage2D:B,compressedTexSubImage3D:W,scissor:le,viewport:ae,reset:Le}}function dg(i,e,t,n,s,r,a){let o=e.has("WEBGL_multisampled_render_to_texture")?e.get("WEBGL_multisampled_render_to_texture"):null,c=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),l=new Oe,h=new WeakMap,f=new Set,u,d=new WeakMap,g=!1;try{g=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function y(w,M){return g?new OffscreenCanvas(w,M):us("canvas")}function m(w,M,D){let B=1,W=je(w);if((W.width>D||W.height>D)&&(B=D/Math.max(W.width,W.height)),B<1)if(typeof HTMLImageElement<"u"&&w instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&w instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&w instanceof ImageBitmap||typeof VideoFrame<"u"&&w instanceof VideoFrame){let ie=Math.floor(B*W.width),se=Math.floor(B*W.height);u===void 0&&(u=y(ie,se));let Y=M?y(ie,se):u;return Y.width=ie,Y.height=se,Y.getContext("2d").drawImage(w,0,0,ie,se),be("WebGLRenderer: Texture has been resized from ("+W.width+"x"+W.height+") to ("+ie+"x"+se+")."),Y}else return"data"in w&&be("WebGLRenderer: Image in DataTexture is too big ("+W.width+"x"+W.height+")."),w;return w}function p(w){return w.generateMipmaps}function T(w){i.generateMipmap(w)}function R(w){return w.isWebGLCubeRenderTarget?i.TEXTURE_CUBE_MAP:w.isWebGL3DRenderTarget?i.TEXTURE_3D:w.isWebGLArrayRenderTarget||w.isCompressedArrayTexture?i.TEXTURE_2D_ARRAY:i.TEXTURE_2D}function v(w,M,D,B,W,ie=!1){if(w!==null){if(i[w]!==void 0)return i[w];be("WebGLRenderer: Attempt to use non-existing WebGL internal format '"+w+"'")}let se;B&&(se=e.get("EXT_texture_norm16"),se||be("WebGLRenderer: Unable to use normalized textures without EXT_texture_norm16 extension"));let Y=M;if(M===i.RED&&(D===i.FLOAT&&(Y=i.R32F),D===i.HALF_FLOAT&&(Y=i.R16F),D===i.UNSIGNED_BYTE&&(Y=i.R8),D===i.UNSIGNED_SHORT&&se&&(Y=se.R16_EXT),D===i.SHORT&&se&&(Y=se.R16_SNORM_EXT)),M===i.RED_INTEGER&&(D===i.UNSIGNED_BYTE&&(Y=i.R8UI),D===i.UNSIGNED_SHORT&&(Y=i.R16UI),D===i.UNSIGNED_INT&&(Y=i.R32UI),D===i.BYTE&&(Y=i.R8I),D===i.SHORT&&(Y=i.R16I),D===i.INT&&(Y=i.R32I)),M===i.RG&&(D===i.FLOAT&&(Y=i.RG32F),D===i.HALF_FLOAT&&(Y=i.RG16F),D===i.UNSIGNED_BYTE&&(Y=i.RG8),D===i.UNSIGNED_SHORT&&se&&(Y=se.RG16_EXT),D===i.SHORT&&se&&(Y=se.RG16_SNORM_EXT)),M===i.RG_INTEGER&&(D===i.UNSIGNED_BYTE&&(Y=i.RG8UI),D===i.UNSIGNED_SHORT&&(Y=i.RG16UI),D===i.UNSIGNED_INT&&(Y=i.RG32UI),D===i.BYTE&&(Y=i.RG8I),D===i.SHORT&&(Y=i.RG16I),D===i.INT&&(Y=i.RG32I)),M===i.RGB_INTEGER&&(D===i.UNSIGNED_BYTE&&(Y=i.RGB8UI),D===i.UNSIGNED_SHORT&&(Y=i.RGB16UI),D===i.UNSIGNED_INT&&(Y=i.RGB32UI),D===i.BYTE&&(Y=i.RGB8I),D===i.SHORT&&(Y=i.RGB16I),D===i.INT&&(Y=i.RGB32I)),M===i.RGBA_INTEGER&&(D===i.UNSIGNED_BYTE&&(Y=i.RGBA8UI),D===i.UNSIGNED_SHORT&&(Y=i.RGBA16UI),D===i.UNSIGNED_INT&&(Y=i.RGBA32UI),D===i.BYTE&&(Y=i.RGBA8I),D===i.SHORT&&(Y=i.RGBA16I),D===i.INT&&(Y=i.RGBA32I)),M===i.RGB&&(D===i.UNSIGNED_SHORT&&se&&(Y=se.RGB16_EXT),D===i.SHORT&&se&&(Y=se.RGB16_SNORM_EXT),D===i.UNSIGNED_INT_5_9_9_9_REV&&(Y=i.RGB9_E5),D===i.UNSIGNED_INT_10F_11F_11F_REV&&(Y=i.R11F_G11F_B10F)),M===i.RGBA){let $=ie?Zs:Fe.getTransfer(W);D===i.FLOAT&&(Y=i.RGBA32F),D===i.HALF_FLOAT&&(Y=i.RGBA16F),D===i.UNSIGNED_BYTE&&(Y=$===$e?i.SRGB8_ALPHA8:i.RGBA8),D===i.UNSIGNED_SHORT&&se&&(Y=se.RGBA16_EXT),D===i.SHORT&&se&&(Y=se.RGBA16_SNORM_EXT),D===i.UNSIGNED_SHORT_4_4_4_4&&(Y=i.RGBA4),D===i.UNSIGNED_SHORT_5_5_5_1&&(Y=i.RGB5_A1)}return(Y===i.R16F||Y===i.R32F||Y===i.RG16F||Y===i.RG32F||Y===i.RGBA16F||Y===i.RGBA32F)&&e.get("EXT_color_buffer_float"),Y}function b(w,M){let D;return w?M===null||M===Sn||M===Cs?D=i.DEPTH24_STENCIL8:M===nn?D=i.DEPTH32F_STENCIL8:M===Rs&&(D=i.DEPTH24_STENCIL8,be("DepthTexture: 16 bit depth attachment is not supported with stencil. Using 24-bit attachment.")):M===null||M===Sn||M===Cs?D=i.DEPTH_COMPONENT24:M===nn?D=i.DEPTH_COMPONENT32F:M===Rs&&(D=i.DEPTH_COMPONENT16),D}function S(w,M){return p(w)===!0||w.isFramebufferTexture&&w.minFilter!==dt&&w.minFilter!==pt?Math.log2(Math.max(M.width,M.height))+1:w.mipmaps!==void 0&&w.mipmaps.length>0?w.mipmaps.length:w.isCompressedTexture&&Array.isArray(w.image)?M.mipmaps.length:1}function A(w){let M=w.target;M.removeEventListener("dispose",A),E(M),M.isVideoTexture&&h.delete(M),M.isHTMLTexture&&f.delete(M)}function _(w){let M=w.target;M.removeEventListener("dispose",_),N(M)}function E(w){let M=n.get(w);if(M.__webglInit===void 0)return;let D=w.source,B=d.get(D);if(B){let W=B[M.__cacheKey];W.usedTimes--,W.usedTimes===0&&P(w),Object.keys(B).length===0&&d.delete(D)}n.remove(w)}function P(w){let M=n.get(w);i.deleteTexture(M.__webglTexture);let D=w.source,B=d.get(D);delete B[M.__cacheKey],a.memory.textures--}function N(w){let M=n.get(w);if(w.depthTexture&&(w.depthTexture.dispose(),n.remove(w.depthTexture)),w.isWebGLCubeRenderTarget)for(let B=0;B<6;B++){if(Array.isArray(M.__webglFramebuffer[B]))for(let W=0;W<M.__webglFramebuffer[B].length;W++)i.deleteFramebuffer(M.__webglFramebuffer[B][W]);else i.deleteFramebuffer(M.__webglFramebuffer[B]);M.__webglDepthbuffer&&i.deleteRenderbuffer(M.__webglDepthbuffer[B])}else{if(Array.isArray(M.__webglFramebuffer))for(let B=0;B<M.__webglFramebuffer.length;B++)i.deleteFramebuffer(M.__webglFramebuffer[B]);else i.deleteFramebuffer(M.__webglFramebuffer);if(M.__webglDepthbuffer&&i.deleteRenderbuffer(M.__webglDepthbuffer),M.__webglMultisampledFramebuffer&&i.deleteFramebuffer(M.__webglMultisampledFramebuffer),M.__webglColorRenderbuffer)for(let B=0;B<M.__webglColorRenderbuffer.length;B++)M.__webglColorRenderbuffer[B]&&i.deleteRenderbuffer(M.__webglColorRenderbuffer[B]);M.__webglDepthRenderbuffer&&i.deleteRenderbuffer(M.__webglDepthRenderbuffer)}let D=w.textures;for(let B=0,W=D.length;B<W;B++){let ie=n.get(D[B]);ie.__webglTexture&&(i.deleteTexture(ie.__webglTexture),a.memory.textures--),n.remove(D[B])}n.remove(w)}let k=0;function H(){k=0}function L(){return k}function V(w){k=w}function K(){let w=k;return w>=s.maxTextures&&be("WebGLTextures: Trying to use "+(w+1)+" texture units while this GPU supports only "+s.maxTextures),k+=1,w}function Z(w){let M=[];return M.push(w.wrapS),M.push(w.wrapT),M.push(w.wrapR||0),M.push(w.magFilter),M.push(w.minFilter),M.push(w.anisotropy),M.push(w.internalFormat),M.push(w.format),M.push(w.type),M.push(w.generateMipmaps),M.push(w.premultiplyAlpha),M.push(w.flipY),M.push(w.unpackAlignment),M.push(w.colorSpace),M.join()}function ne(w,M){let D=n.get(w);if(w.isVideoTexture&&I(w),w.isRenderTargetTexture===!1&&w.isExternalTexture!==!0&&w.version>0&&D.__version!==w.version){let B=w.image;if(B===null)be("WebGLRenderer: Texture marked for update but no image data found.");else if(B.complete===!1)be("WebGLRenderer: Texture marked for update but image is incomplete");else{ge(D,w,M);return}}else w.isExternalTexture&&(D.__webglTexture=w.sourceTexture?w.sourceTexture:null);t.bindTexture(i.TEXTURE_2D,D.__webglTexture,i.TEXTURE0+M)}function X(w,M){let D=n.get(w);if(w.isRenderTargetTexture===!1&&w.version>0&&D.__version!==w.version){ge(D,w,M);return}else w.isExternalTexture&&(D.__webglTexture=w.sourceTexture?w.sourceTexture:null);t.bindTexture(i.TEXTURE_2D_ARRAY,D.__webglTexture,i.TEXTURE0+M)}function Q(w,M){let D=n.get(w);if(w.isRenderTargetTexture===!1&&w.version>0&&D.__version!==w.version){ge(D,w,M);return}t.bindTexture(i.TEXTURE_3D,D.__webglTexture,i.TEXTURE0+M)}function te(w,M){let D=n.get(w);if(w.isCubeDepthTexture!==!0&&w.version>0&&D.__version!==w.version){Pe(D,w,M);return}t.bindTexture(i.TEXTURE_CUBE_MAP,D.__webglTexture,i.TEXTURE0+M)}let Ae={[di]:i.REPEAT,[cn]:i.CLAMP_TO_EDGE,[ls]:i.MIRRORED_REPEAT},Te={[dt]:i.NEAREST,[Fa]:i.NEAREST_MIPMAP_NEAREST,[Bi]:i.NEAREST_MIPMAP_LINEAR,[pt]:i.LINEAR,[As]:i.LINEAR_MIPMAP_NEAREST,[bn]:i.LINEAR_MIPMAP_LINEAR},st={[gu]:i.NEVER,[bu]:i.ALWAYS,[_u]:i.LESS,[So]:i.LEQUAL,[xu]:i.EQUAL,[wo]:i.GEQUAL,[yu]:i.GREATER,[vu]:i.NOTEQUAL};function Xe(w,M){if(M.type===nn&&e.has("OES_texture_float_linear")===!1&&(M.magFilter===pt||M.magFilter===As||M.magFilter===Bi||M.magFilter===bn||M.minFilter===pt||M.minFilter===As||M.minFilter===Bi||M.minFilter===bn)&&be("WebGLRenderer: Unable to use linear filtering with floating point textures. OES_texture_float_linear not supported on this device."),i.texParameteri(w,i.TEXTURE_WRAP_S,Ae[M.wrapS]),i.texParameteri(w,i.TEXTURE_WRAP_T,Ae[M.wrapT]),(w===i.TEXTURE_3D||w===i.TEXTURE_2D_ARRAY)&&i.texParameteri(w,i.TEXTURE_WRAP_R,Ae[M.wrapR]),i.texParameteri(w,i.TEXTURE_MAG_FILTER,Te[M.magFilter]),i.texParameteri(w,i.TEXTURE_MIN_FILTER,Te[M.minFilter]),M.compareFunction&&(i.texParameteri(w,i.TEXTURE_COMPARE_MODE,i.COMPARE_REF_TO_TEXTURE),i.texParameteri(w,i.TEXTURE_COMPARE_FUNC,st[M.compareFunction])),e.has("EXT_texture_filter_anisotropic")===!0){if(M.magFilter===dt||M.minFilter!==Bi&&M.minFilter!==bn||M.type===nn&&e.has("OES_texture_float_linear")===!1)return;if(M.anisotropy>1||n.get(M).__currentAnisotropy){let D=e.get("EXT_texture_filter_anisotropic");i.texParameterf(w,D.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(M.anisotropy,s.getMaxAnisotropy())),n.get(M).__currentAnisotropy=M.anisotropy}}}function Ze(w,M){let D=!1;w.__webglInit===void 0&&(w.__webglInit=!0,M.addEventListener("dispose",A));let B=M.source,W=d.get(B);W===void 0&&(W={},d.set(B,W));let ie=Z(M);if(ie!==w.__cacheKey){W[ie]===void 0&&(W[ie]={texture:i.createTexture(),usedTimes:0},a.memory.textures++,D=!0),W[ie].usedTimes++;let se=W[w.__cacheKey];se!==void 0&&(W[w.__cacheKey].usedTimes--,se.usedTimes===0&&P(M)),w.__cacheKey=ie,w.__webglTexture=W[ie].texture}return D}function q(w,M,D){return Math.floor(Math.floor(w/D)/M)}function j(w,M,D,B){let ie=w.updateRanges;if(ie.length===0)t.texSubImage2D(i.TEXTURE_2D,0,0,0,M.width,M.height,D,B,M.data);else{ie.sort((Se,le)=>Se.start-le.start);let se=0;for(let Se=1;Se<ie.length;Se++){let le=ie[se],ae=ie[Se],we=le.start+le.count,Re=q(ae.start,M.width,4),Le=q(le.start,M.width,4);ae.start<=we+1&&Re===Le&&q(ae.start+ae.count-1,M.width,4)===Re?le.count=Math.max(le.count,ae.start+ae.count-le.start):(++se,ie[se]=ae)}ie.length=se+1;let Y=t.getParameter(i.UNPACK_ROW_LENGTH),$=t.getParameter(i.UNPACK_SKIP_PIXELS),re=t.getParameter(i.UNPACK_SKIP_ROWS);t.pixelStorei(i.UNPACK_ROW_LENGTH,M.width);for(let Se=0,le=ie.length;Se<le;Se++){let ae=ie[Se],we=Math.floor(ae.start/4),Re=Math.ceil(ae.count/4),Le=we%M.width,z=Math.floor(we/M.width),oe=Re,J=1;t.pixelStorei(i.UNPACK_SKIP_PIXELS,Le),t.pixelStorei(i.UNPACK_SKIP_ROWS,z),t.texSubImage2D(i.TEXTURE_2D,0,Le,z,oe,J,D,B,M.data)}w.clearUpdateRanges(),t.pixelStorei(i.UNPACK_ROW_LENGTH,Y),t.pixelStorei(i.UNPACK_SKIP_PIXELS,$),t.pixelStorei(i.UNPACK_SKIP_ROWS,re)}}function ge(w,M,D){let B=i.TEXTURE_2D;(M.isDataArrayTexture||M.isCompressedArrayTexture)&&(B=i.TEXTURE_2D_ARRAY),M.isData3DTexture&&(B=i.TEXTURE_3D);let W=Ze(w,M),ie=M.source;t.bindTexture(B,w.__webglTexture,i.TEXTURE0+D);let se=n.get(ie);if(ie.version!==se.__version||W===!0){if(t.activeTexture(i.TEXTURE0+D),(typeof ImageBitmap<"u"&&M.image instanceof ImageBitmap)===!1){let J=Fe.getPrimaries(Fe.workingColorSpace),ce=M.colorSpace===ei?null:Fe.getPrimaries(M.colorSpace),de=M.colorSpace===ei||J===ce?i.NONE:i.BROWSER_DEFAULT_WEBGL;t.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,M.flipY),t.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,M.premultiplyAlpha),t.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,de)}t.pixelStorei(i.UNPACK_ALIGNMENT,M.unpackAlignment);let $=m(M.image,!1,s.maxTextureSize);$=zt(M,$);let re=r.convert(M.format,M.colorSpace),Se=r.convert(M.type),le=v(M.internalFormat,re,Se,M.normalized,M.colorSpace,M.isVideoTexture);Xe(B,M);let ae,we=M.mipmaps,Re=M.isVideoTexture!==!0,Le=se.__version===void 0||W===!0,z=ie.dataReady,oe=S(M,$);if(M.isDepthTexture)le=b(M.format===_i,M.type),Le&&(Re?t.texStorage2D(i.TEXTURE_2D,1,le,$.width,$.height):t.texImage2D(i.TEXTURE_2D,0,le,$.width,$.height,0,re,Se,null));else if(M.isDataTexture)if(we.length>0){Re&&Le&&t.texStorage2D(i.TEXTURE_2D,oe,le,we[0].width,we[0].height);for(let J=0,ce=we.length;J<ce;J++)ae=we[J],Re?z&&t.texSubImage2D(i.TEXTURE_2D,J,0,0,ae.width,ae.height,re,Se,ae.data):t.texImage2D(i.TEXTURE_2D,J,le,ae.width,ae.height,0,re,Se,ae.data);M.generateMipmaps=!1}else Re?(Le&&t.texStorage2D(i.TEXTURE_2D,oe,le,$.width,$.height),z&&j(M,$,re,Se)):t.texImage2D(i.TEXTURE_2D,0,le,$.width,$.height,0,re,Se,$.data);else if(M.isCompressedTexture)if(M.isCompressedArrayTexture){Re&&Le&&t.texStorage3D(i.TEXTURE_2D_ARRAY,oe,le,we[0].width,we[0].height,$.depth);for(let J=0,ce=we.length;J<ce;J++)if(ae=we[J],M.format!==sn)if(re!==null)if(Re){if(z)if(M.layerUpdates.size>0){let de=tl(ae.width,ae.height,M.format,M.type);for(let ee of M.layerUpdates){let Ee=ae.data.subarray(ee*de/ae.data.BYTES_PER_ELEMENT,(ee+1)*de/ae.data.BYTES_PER_ELEMENT);t.compressedTexSubImage3D(i.TEXTURE_2D_ARRAY,J,0,0,ee,ae.width,ae.height,1,re,Ee)}}else t.compressedTexSubImage3D(i.TEXTURE_2D_ARRAY,J,0,0,0,ae.width,ae.height,$.depth,re,ae.data)}else t.compressedTexImage3D(i.TEXTURE_2D_ARRAY,J,le,ae.width,ae.height,$.depth,0,ae.data,0,0);else be("WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()");else Re?z&&t.texSubImage3D(i.TEXTURE_2D_ARRAY,J,0,0,0,ae.width,ae.height,$.depth,re,Se,ae.data):t.texImage3D(i.TEXTURE_2D_ARRAY,J,le,ae.width,ae.height,$.depth,0,re,Se,ae.data);M.layerUpdates.size>0&&M.clearLayerUpdates()}else{Re&&Le&&t.texStorage2D(i.TEXTURE_2D,oe,le,we[0].width,we[0].height);for(let J=0,ce=we.length;J<ce;J++)ae=we[J],M.format!==sn?re!==null?Re?z&&t.compressedTexSubImage2D(i.TEXTURE_2D,J,0,0,ae.width,ae.height,re,ae.data):t.compressedTexImage2D(i.TEXTURE_2D,J,le,ae.width,ae.height,0,ae.data):be("WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):Re?z&&t.texSubImage2D(i.TEXTURE_2D,J,0,0,ae.width,ae.height,re,Se,ae.data):t.texImage2D(i.TEXTURE_2D,J,le,ae.width,ae.height,0,re,Se,ae.data)}else if(M.isDataArrayTexture)if(Re){if(Le&&t.texStorage3D(i.TEXTURE_2D_ARRAY,oe,le,$.width,$.height,$.depth),z)if(M.layerUpdates.size>0){let J=tl($.width,$.height,M.format,M.type);for(let ce of M.layerUpdates){let de=$.data.subarray(ce*J/$.data.BYTES_PER_ELEMENT,(ce+1)*J/$.data.BYTES_PER_ELEMENT);t.texSubImage3D(i.TEXTURE_2D_ARRAY,0,0,0,ce,$.width,$.height,1,re,Se,de)}M.clearLayerUpdates()}else t.texSubImage3D(i.TEXTURE_2D_ARRAY,0,0,0,0,$.width,$.height,$.depth,re,Se,$.data)}else t.texImage3D(i.TEXTURE_2D_ARRAY,0,le,$.width,$.height,$.depth,0,re,Se,$.data);else if(M.isData3DTexture)Re?(Le&&t.texStorage3D(i.TEXTURE_3D,oe,le,$.width,$.height,$.depth),z&&t.texSubImage3D(i.TEXTURE_3D,0,0,0,0,$.width,$.height,$.depth,re,Se,$.data)):t.texImage3D(i.TEXTURE_3D,0,le,$.width,$.height,$.depth,0,re,Se,$.data);else if(M.isFramebufferTexture){if(Le)if(Re)t.texStorage2D(i.TEXTURE_2D,oe,le,$.width,$.height);else{let J=$.width,ce=$.height;for(let de=0;de<oe;de++)t.texImage2D(i.TEXTURE_2D,de,le,J,ce,0,re,Se,null),J>>=1,ce>>=1}}else if(M.isHTMLTexture){if("texElementImage2D"in i){let J=i.canvas;if(J.hasAttribute("layoutsubtree")||J.setAttribute("layoutsubtree","true"),$.parentNode!==J){J.appendChild($),f.add(M),J.onpaint=ce=>{let de=ce.changedElements;for(let ee of f)de.includes(ee.image)&&(ee.needsUpdate=!0)},J.requestPaint();return}if(i.texElementImage2D.length===3)i.texElementImage2D(i.TEXTURE_2D,i.RGBA8,$);else{let de=i.RGBA,ee=i.RGBA,Ee=i.UNSIGNED_BYTE;i.texElementImage2D(i.TEXTURE_2D,0,de,ee,Ee,$)}i.texParameteri(i.TEXTURE_2D,i.TEXTURE_MIN_FILTER,i.LINEAR),i.texParameteri(i.TEXTURE_2D,i.TEXTURE_WRAP_S,i.CLAMP_TO_EDGE),i.texParameteri(i.TEXTURE_2D,i.TEXTURE_WRAP_T,i.CLAMP_TO_EDGE)}}else if(we.length>0){if(Re&&Le){let J=je(we[0]);t.texStorage2D(i.TEXTURE_2D,oe,le,J.width,J.height)}for(let J=0,ce=we.length;J<ce;J++)ae=we[J],Re?z&&t.texSubImage2D(i.TEXTURE_2D,J,0,0,re,Se,ae):t.texImage2D(i.TEXTURE_2D,J,le,re,Se,ae);M.generateMipmaps=!1}else if(Re){if(Le){let J=je($);t.texStorage2D(i.TEXTURE_2D,oe,le,J.width,J.height)}z&&t.texSubImage2D(i.TEXTURE_2D,0,0,0,re,Se,$)}else t.texImage2D(i.TEXTURE_2D,0,le,re,Se,$);p(M)&&T(B),se.__version=ie.version,M.onUpdate&&M.onUpdate(M)}w.__version=M.version}function Pe(w,M,D){if(M.image.length!==6)return;let B=Ze(w,M),W=M.source;t.bindTexture(i.TEXTURE_CUBE_MAP,w.__webglTexture,i.TEXTURE0+D);let ie=n.get(W);if(W.version!==ie.__version||B===!0){t.activeTexture(i.TEXTURE0+D);let se=Fe.getPrimaries(Fe.workingColorSpace),Y=M.colorSpace===ei?null:Fe.getPrimaries(M.colorSpace),$=M.colorSpace===ei||se===Y?i.NONE:i.BROWSER_DEFAULT_WEBGL;t.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,M.flipY),t.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,M.premultiplyAlpha),t.pixelStorei(i.UNPACK_ALIGNMENT,M.unpackAlignment),t.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,$);let re=M.isCompressedTexture||M.image[0].isCompressedTexture,Se=M.image[0]&&M.image[0].isDataTexture,le=[];for(let ee=0;ee<6;ee++)!re&&!Se?le[ee]=m(M.image[ee],!0,s.maxCubemapSize):le[ee]=Se?M.image[ee].image:M.image[ee],le[ee]=zt(M,le[ee]);let ae=le[0],we=r.convert(M.format,M.colorSpace),Re=r.convert(M.type),Le=v(M.internalFormat,we,Re,M.normalized,M.colorSpace),z=M.isVideoTexture!==!0,oe=ie.__version===void 0||B===!0,J=W.dataReady,ce=S(M,ae);Xe(i.TEXTURE_CUBE_MAP,M);let de;if(re){z&&oe&&t.texStorage2D(i.TEXTURE_CUBE_MAP,ce,Le,ae.width,ae.height);for(let ee=0;ee<6;ee++){de=le[ee].mipmaps;for(let Ee=0;Ee<de.length;Ee++){let ye=de[Ee];M.format!==sn?we!==null?z?J&&t.compressedTexSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee,0,0,ye.width,ye.height,we,ye.data):t.compressedTexImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee,Le,ye.width,ye.height,0,ye.data):be("WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):z?J&&t.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee,0,0,ye.width,ye.height,we,Re,ye.data):t.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee,Le,ye.width,ye.height,0,we,Re,ye.data)}}}else{if(de=M.mipmaps,z&&oe){de.length>0&&ce++;let ee=je(le[0]);t.texStorage2D(i.TEXTURE_CUBE_MAP,ce,Le,ee.width,ee.height)}for(let ee=0;ee<6;ee++)if(Se){z?J&&t.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,0,0,0,le[ee].width,le[ee].height,we,Re,le[ee].data):t.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,0,Le,le[ee].width,le[ee].height,0,we,Re,le[ee].data);for(let Ee=0;Ee<de.length;Ee++){let at=de[Ee].image[ee].image;z?J&&t.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee+1,0,0,at.width,at.height,we,Re,at.data):t.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee+1,Le,at.width,at.height,0,we,Re,at.data)}}else{z?J&&t.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,0,0,0,we,Re,le[ee]):t.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,0,Le,we,Re,le[ee]);for(let Ee=0;Ee<de.length;Ee++){let ye=de[Ee];z?J&&t.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee+1,0,0,we,Re,ye.image[ee]):t.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ee,Ee+1,Le,we,Re,ye.image[ee])}}}p(M)&&T(i.TEXTURE_CUBE_MAP),ie.__version=W.version,M.onUpdate&&M.onUpdate(M)}w.__version=M.version}function me(w,M,D,B,W,ie){let se=r.convert(D.format,D.colorSpace),Y=r.convert(D.type),$=v(D.internalFormat,se,Y,D.normalized,D.colorSpace),re=n.get(M),Se=n.get(D);if(Se.__renderTarget=M,!re.__hasExternalTextures){let le=Math.max(1,M.width>>ie),ae=Math.max(1,M.height>>ie);W===i.TEXTURE_3D||W===i.TEXTURE_2D_ARRAY?t.texImage3D(W,ie,$,le,ae,M.depth,0,se,Y,null):t.texImage2D(W,ie,$,le,ae,0,se,Y,null)}t.bindFramebuffer(i.FRAMEBUFFER,w),Mt(M)?o.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,B,W,Se.__webglTexture,0,ht(M)):(W===i.TEXTURE_2D||W>=i.TEXTURE_CUBE_MAP_POSITIVE_X&&W<=i.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&i.framebufferTexture2D(i.FRAMEBUFFER,B,W,Se.__webglTexture,ie),t.bindFramebuffer(i.FRAMEBUFFER,null)}function Be(w,M,D){if(i.bindRenderbuffer(i.RENDERBUFFER,w),M.depthBuffer){let B=M.depthTexture,W=B&&B.isDepthTexture?B.type:null,ie=b(M.stencilBuffer,W),se=M.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT;Mt(M)?o.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,ht(M),ie,M.width,M.height):D?i.renderbufferStorageMultisample(i.RENDERBUFFER,ht(M),ie,M.width,M.height):i.renderbufferStorage(i.RENDERBUFFER,ie,M.width,M.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,se,i.RENDERBUFFER,w)}else{let B=M.textures;for(let W=0;W<B.length;W++){let ie=B[W],se=r.convert(ie.format,ie.colorSpace),Y=r.convert(ie.type),$=v(ie.internalFormat,se,Y,ie.normalized,ie.colorSpace);Mt(M)?o.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,ht(M),$,M.width,M.height):D?i.renderbufferStorageMultisample(i.RENDERBUFFER,ht(M),$,M.width,M.height):i.renderbufferStorage(i.RENDERBUFFER,$,M.width,M.height)}}i.bindRenderbuffer(i.RENDERBUFFER,null)}function yt(w,M,D){let B=M.isWebGLCubeRenderTarget===!0;if(t.bindFramebuffer(i.FRAMEBUFFER,w),!(M.depthTexture&&M.depthTexture.isDepthTexture))throw new Error("THREE.WebGLTextures: renderTarget.depthTexture must be an instance of THREE.DepthTexture.");let W=n.get(M.depthTexture);if(W.__renderTarget=M,(!W.__webglTexture||M.depthTexture.image.width!==M.width||M.depthTexture.image.height!==M.height)&&(M.depthTexture.image.width=M.width,M.depthTexture.image.height=M.height,M.depthTexture.needsUpdate=!0),B){if(W.__webglInit===void 0&&(W.__webglInit=!0,M.depthTexture.addEventListener("dispose",A)),W.__webglTexture===void 0){W.__webglTexture=i.createTexture(),t.bindTexture(i.TEXTURE_CUBE_MAP,W.__webglTexture),Xe(i.TEXTURE_CUBE_MAP,M.depthTexture);let re=r.convert(M.depthTexture.format),Se=r.convert(M.depthTexture.type),le;M.depthTexture.format===In?le=i.DEPTH_COMPONENT24:M.depthTexture.format===_i&&(le=i.DEPTH24_STENCIL8);for(let ae=0;ae<6;ae++)i.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+ae,0,le,M.width,M.height,0,re,Se,null)}}else ne(M.depthTexture,0);let ie=W.__webglTexture,se=ht(M),Y=B?i.TEXTURE_CUBE_MAP_POSITIVE_X+D:i.TEXTURE_2D,$=M.depthTexture.format===_i?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT;if(M.depthTexture.format===In)Mt(M)?o.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,$,Y,ie,0,se):i.framebufferTexture2D(i.FRAMEBUFFER,$,Y,ie,0);else if(M.depthTexture.format===_i)Mt(M)?o.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,$,Y,ie,0,se):i.framebufferTexture2D(i.FRAMEBUFFER,$,Y,ie,0);else throw new Error("THREE.WebGLTextures: Unknown depthTexture format.")}function Ve(w){let M=n.get(w),D=w.isWebGLCubeRenderTarget===!0;if(M.__boundDepthTexture!==w.depthTexture){let B=w.depthTexture;if(M.__depthDisposeCallback&&M.__depthDisposeCallback(),B){let W=()=>{delete M.__boundDepthTexture,delete M.__depthDisposeCallback,B.removeEventListener("dispose",W)};B.addEventListener("dispose",W),M.__depthDisposeCallback=W}M.__boundDepthTexture=B}if(w.depthTexture&&!M.__autoAllocateDepthBuffer)if(D)for(let B=0;B<6;B++)yt(M.__webglFramebuffer[B],w,B);else{let B=w.texture.mipmaps;B&&B.length>0?yt(M.__webglFramebuffer[0],w,0):yt(M.__webglFramebuffer,w,0)}else if(D){M.__webglDepthbuffer=[];for(let B=0;B<6;B++)if(t.bindFramebuffer(i.FRAMEBUFFER,M.__webglFramebuffer[B]),M.__webglDepthbuffer[B]===void 0)M.__webglDepthbuffer[B]=i.createRenderbuffer(),Be(M.__webglDepthbuffer[B],w,!1);else{let W=w.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT,ie=M.__webglDepthbuffer[B];i.bindRenderbuffer(i.RENDERBUFFER,ie),i.framebufferRenderbuffer(i.FRAMEBUFFER,W,i.RENDERBUFFER,ie)}}else{let B=w.texture.mipmaps;if(B&&B.length>0?t.bindFramebuffer(i.FRAMEBUFFER,M.__webglFramebuffer[0]):t.bindFramebuffer(i.FRAMEBUFFER,M.__webglFramebuffer),M.__webglDepthbuffer===void 0)M.__webglDepthbuffer=i.createRenderbuffer(),Be(M.__webglDepthbuffer,w,!1);else{let W=w.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT,ie=M.__webglDepthbuffer;i.bindRenderbuffer(i.RENDERBUFFER,ie),i.framebufferRenderbuffer(i.FRAMEBUFFER,W,i.RENDERBUFFER,ie)}}t.bindFramebuffer(i.FRAMEBUFFER,null)}function Ye(w,M,D){let B=n.get(w);M!==void 0&&me(B.__webglFramebuffer,w,w.texture,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,0),D!==void 0&&Ve(w)}function rt(w){let M=w.texture,D=n.get(w),B=n.get(M);w.addEventListener("dispose",_);let W=w.textures,ie=w.isWebGLCubeRenderTarget===!0,se=W.length>1;if(se||(B.__webglTexture===void 0&&(B.__webglTexture=i.createTexture()),B.__version=M.version,a.memory.textures++),ie){D.__webglFramebuffer=[];for(let Y=0;Y<6;Y++)if(M.mipmaps&&M.mipmaps.length>0){D.__webglFramebuffer[Y]=[];for(let $=0;$<M.mipmaps.length;$++)D.__webglFramebuffer[Y][$]=i.createFramebuffer()}else D.__webglFramebuffer[Y]=i.createFramebuffer()}else{if(M.mipmaps&&M.mipmaps.length>0){D.__webglFramebuffer=[];for(let Y=0;Y<M.mipmaps.length;Y++)D.__webglFramebuffer[Y]=i.createFramebuffer()}else D.__webglFramebuffer=i.createFramebuffer();if(se)for(let Y=0,$=W.length;Y<$;Y++){let re=n.get(W[Y]);re.__webglTexture===void 0&&(re.__webglTexture=i.createTexture(),a.memory.textures++)}if(w.samples>0&&Mt(w)===!1){D.__webglMultisampledFramebuffer=i.createFramebuffer(),D.__webglColorRenderbuffer=[],t.bindFramebuffer(i.FRAMEBUFFER,D.__webglMultisampledFramebuffer);for(let Y=0;Y<W.length;Y++){let $=W[Y];D.__webglColorRenderbuffer[Y]=i.createRenderbuffer(),i.bindRenderbuffer(i.RENDERBUFFER,D.__webglColorRenderbuffer[Y]);let re=r.convert($.format,$.colorSpace),Se=r.convert($.type),le=v($.internalFormat,re,Se,$.normalized,$.colorSpace,w.isXRRenderTarget===!0),ae=ht(w);i.renderbufferStorageMultisample(i.RENDERBUFFER,ae,le,w.width,w.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+Y,i.RENDERBUFFER,D.__webglColorRenderbuffer[Y])}i.bindRenderbuffer(i.RENDERBUFFER,null),w.depthBuffer&&(D.__webglDepthRenderbuffer=i.createRenderbuffer(),Be(D.__webglDepthRenderbuffer,w,!0)),t.bindFramebuffer(i.FRAMEBUFFER,null)}}if(ie){t.bindTexture(i.TEXTURE_CUBE_MAP,B.__webglTexture),Xe(i.TEXTURE_CUBE_MAP,M);for(let Y=0;Y<6;Y++)if(M.mipmaps&&M.mipmaps.length>0)for(let $=0;$<M.mipmaps.length;$++)me(D.__webglFramebuffer[Y][$],w,M,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+Y,$);else me(D.__webglFramebuffer[Y],w,M,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+Y,0);p(M)&&T(i.TEXTURE_CUBE_MAP),t.unbindTexture()}else if(se){for(let Y=0,$=W.length;Y<$;Y++){let re=W[Y],Se=n.get(re),le=i.TEXTURE_2D;(w.isWebGL3DRenderTarget||w.isWebGLArrayRenderTarget)&&(le=w.isWebGL3DRenderTarget?i.TEXTURE_3D:i.TEXTURE_2D_ARRAY),t.bindTexture(le,Se.__webglTexture),Xe(le,re),me(D.__webglFramebuffer,w,re,i.COLOR_ATTACHMENT0+Y,le,0),p(re)&&T(le)}t.unbindTexture()}else{let Y=i.TEXTURE_2D;if((w.isWebGL3DRenderTarget||w.isWebGLArrayRenderTarget)&&(Y=w.isWebGL3DRenderTarget?i.TEXTURE_3D:i.TEXTURE_2D_ARRAY),t.bindTexture(Y,B.__webglTexture),Xe(Y,M),M.mipmaps&&M.mipmaps.length>0)for(let $=0;$<M.mipmaps.length;$++)me(D.__webglFramebuffer[$],w,M,i.COLOR_ATTACHMENT0,Y,$);else me(D.__webglFramebuffer,w,M,i.COLOR_ATTACHMENT0,Y,0);p(M)&&T(Y),t.unbindTexture()}w.depthBuffer&&Ve(w)}function We(w){let M=w.textures;for(let D=0,B=M.length;D<B;D++){let W=M[D];if(p(W)){let ie=R(w),se=n.get(W).__webglTexture;t.bindTexture(ie,se),T(ie),t.unbindTexture()}}}let lt=[],Et=[];function Ht(w){if(w.samples>0){if(Mt(w)===!1){let M=w.textures,D=w.width,B=w.height,W=i.COLOR_BUFFER_BIT,ie=w.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT,se=n.get(w),Y=M.length>1;if(Y)for(let re=0;re<M.length;re++)t.bindFramebuffer(i.FRAMEBUFFER,se.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+re,i.RENDERBUFFER,null),t.bindFramebuffer(i.FRAMEBUFFER,se.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+re,i.TEXTURE_2D,null,0);t.bindFramebuffer(i.READ_FRAMEBUFFER,se.__webglMultisampledFramebuffer);let $=w.texture.mipmaps;$&&$.length>0?t.bindFramebuffer(i.DRAW_FRAMEBUFFER,se.__webglFramebuffer[0]):t.bindFramebuffer(i.DRAW_FRAMEBUFFER,se.__webglFramebuffer);for(let re=0;re<M.length;re++){if(w.resolveDepthBuffer&&(w.depthBuffer&&(W|=i.DEPTH_BUFFER_BIT),w.stencilBuffer&&w.resolveStencilBuffer&&(W|=i.STENCIL_BUFFER_BIT)),Y){i.framebufferRenderbuffer(i.READ_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.RENDERBUFFER,se.__webglColorRenderbuffer[re]);let Se=n.get(M[re]).__webglTexture;i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,Se,0)}i.blitFramebuffer(0,0,D,B,0,0,D,B,W,i.NEAREST),c===!0&&(lt.length=0,Et.length=0,lt.push(i.COLOR_ATTACHMENT0+re),w.depthBuffer&&w.storeMultisampledDepthBuffer===!1&&(lt.push(ie),Et.push(ie),i.invalidateFramebuffer(i.DRAW_FRAMEBUFFER,Et)),i.invalidateFramebuffer(i.READ_FRAMEBUFFER,lt))}if(t.bindFramebuffer(i.READ_FRAMEBUFFER,null),t.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),Y)for(let re=0;re<M.length;re++){t.bindFramebuffer(i.FRAMEBUFFER,se.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+re,i.RENDERBUFFER,se.__webglColorRenderbuffer[re]);let Se=n.get(M[re]).__webglTexture;t.bindFramebuffer(i.FRAMEBUFFER,se.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+re,i.TEXTURE_2D,Se,0)}t.bindFramebuffer(i.DRAW_FRAMEBUFFER,se.__webglMultisampledFramebuffer)}else if(w.depthBuffer&&w.storeMultisampledDepthBuffer===!1&&c){let M=w.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT;i.invalidateFramebuffer(i.DRAW_FRAMEBUFFER,[M])}}}function ht(w){return Math.min(s.maxSamples,w.samples)}function Mt(w){let M=n.get(w);return w.samples>0&&e.has("WEBGL_multisampled_render_to_texture")===!0&&M.__useRenderToTexture!==!1}function I(w){let M=a.render.frame;h.get(w)!==M&&(h.set(w,M),w.update())}function zt(w,M){let D=w.colorSpace,B=w.format,W=w.type;return w.isCompressedTexture===!0||w.isVideoTexture===!0||D!==kt&&D!==ei&&(Fe.getTransfer(D)===$e?(B!==sn||W!==Zt)&&be("WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):ze("WebGLTextures: Unsupported texture color space:",D)),M}function je(w){return typeof HTMLImageElement<"u"&&w instanceof HTMLImageElement?(l.width=w.naturalWidth||w.width,l.height=w.naturalHeight||w.height):typeof VideoFrame<"u"&&w instanceof VideoFrame?(l.width=w.displayWidth,l.height=w.displayHeight):(l.width=w.width,l.height=w.height),l}this.allocateTextureUnit=K,this.resetTextureUnits=H,this.getTextureUnits=L,this.setTextureUnits=V,this.setTexture2D=ne,this.setTexture2DArray=X,this.setTexture3D=Q,this.setTextureCube=te,this.rebindTextures=Ye,this.setupRenderTarget=rt,this.updateRenderTargetMipmap=We,this.updateMultisampleRenderTarget=Ht,this.setupDepthRenderbuffer=Ve,this.setupFrameBufferTexture=me,this.useMultisampledRTT=Mt,this.isReversedDepthBuffer=function(){return t.buffers.depth.getReversed()}}function pg(i,e){function t(n,s=ei){let r,a=Fe.getTransfer(s);if(n===Zt)return i.UNSIGNED_BYTE;if(n===ka)return i.UNSIGNED_SHORT_4_4_4_4;if(n===Va)return i.UNSIGNED_SHORT_5_5_5_1;if(n===Wc)return i.UNSIGNED_INT_5_9_9_9_REV;if(n===Xc)return i.UNSIGNED_INT_10F_11F_11F_REV;if(n===Gc)return i.BYTE;if(n===Hc)return i.SHORT;if(n===Rs)return i.UNSIGNED_SHORT;if(n===Ba)return i.INT;if(n===Sn)return i.UNSIGNED_INT;if(n===nn)return i.FLOAT;if(n===wn)return i.HALF_FLOAT;if(n===qc)return i.ALPHA;if(n===Yc)return i.RGB;if(n===sn)return i.RGBA;if(n===In)return i.DEPTH_COMPONENT;if(n===_i)return i.DEPTH_STENCIL;if(n===Ga)return i.RED;if(n===Ha)return i.RED_INTEGER;if(n===xi)return i.RG;if(n===Wa)return i.RG_INTEGER;if(n===Xa)return i.RGBA_INTEGER;if(n===yr||n===vr||n===br||n===Sr)if(a===$e)if(r=e.get("WEBGL_compressed_texture_s3tc_srgb"),r!==null){if(n===yr)return r.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(n===vr)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(n===br)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(n===Sr)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(r=e.get("WEBGL_compressed_texture_s3tc"),r!==null){if(n===yr)return r.COMPRESSED_RGB_S3TC_DXT1_EXT;if(n===vr)return r.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(n===br)return r.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(n===Sr)return r.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(n===qa||n===Ya||n===Za||n===Ka)if(r=e.get("WEBGL_compressed_texture_pvrtc"),r!==null){if(n===qa)return r.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(n===Ya)return r.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(n===Za)return r.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(n===Ka)return r.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(n===Ja||n===$a||n===ja||n===Qa||n===eo||n===wr||n===to)if(r=e.get("WEBGL_compressed_texture_etc"),r!==null){if(n===Ja||n===$a)return a===$e?r.COMPRESSED_SRGB8_ETC2:r.COMPRESSED_RGB8_ETC2;if(n===ja)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:r.COMPRESSED_RGBA8_ETC2_EAC;if(n===Qa)return r.COMPRESSED_R11_EAC;if(n===eo)return r.COMPRESSED_SIGNED_R11_EAC;if(n===wr)return r.COMPRESSED_RG11_EAC;if(n===to)return r.COMPRESSED_SIGNED_RG11_EAC}else return null;if(n===no||n===io||n===so||n===ro||n===ao||n===oo||n===co||n===lo||n===ho||n===uo||n===fo||n===po||n===mo||n===Mo)if(r=e.get("WEBGL_compressed_texture_astc"),r!==null){if(n===no)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:r.COMPRESSED_RGBA_ASTC_4x4_KHR;if(n===io)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:r.COMPRESSED_RGBA_ASTC_5x4_KHR;if(n===so)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:r.COMPRESSED_RGBA_ASTC_5x5_KHR;if(n===ro)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:r.COMPRESSED_RGBA_ASTC_6x5_KHR;if(n===ao)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:r.COMPRESSED_RGBA_ASTC_6x6_KHR;if(n===oo)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:r.COMPRESSED_RGBA_ASTC_8x5_KHR;if(n===co)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:r.COMPRESSED_RGBA_ASTC_8x6_KHR;if(n===lo)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:r.COMPRESSED_RGBA_ASTC_8x8_KHR;if(n===ho)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:r.COMPRESSED_RGBA_ASTC_10x5_KHR;if(n===uo)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:r.COMPRESSED_RGBA_ASTC_10x6_KHR;if(n===fo)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:r.COMPRESSED_RGBA_ASTC_10x8_KHR;if(n===po)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:r.COMPRESSED_RGBA_ASTC_10x10_KHR;if(n===mo)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:r.COMPRESSED_RGBA_ASTC_12x10_KHR;if(n===Mo)return a===$e?r.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:r.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(n===go||n===_o||n===xo)if(r=e.get("EXT_texture_compression_bptc"),r!==null){if(n===go)return a===$e?r.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:r.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(n===_o)return r.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(n===xo)return r.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(n===yo||n===vo||n===Tr||n===bo)if(r=e.get("EXT_texture_compression_rgtc"),r!==null){if(n===yo)return r.COMPRESSED_RED_RGTC1_EXT;if(n===vo)return r.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(n===Tr)return r.COMPRESSED_RED_GREEN_RGTC2_EXT;if(n===bo)return r.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return n===Cs?i.UNSIGNED_INT_24_8:i[n]!==void 0?i[n]:null}return{convert:t}}var mg=`
void main() {

	gl_Position = vec4( position, 1.0 );

}`,Mg=`
uniform sampler2DArray depthColor;
uniform float depthWidth;
uniform float depthHeight;

void main() {

	vec2 coord = vec2( gl_FragCoord.x / depthWidth, gl_FragCoord.y / depthHeight );

	if ( coord.x >= 1.0 ) {

		gl_FragDepth = texture( depthColor, vec3( coord.x - 1.0, coord.y, 1 ) ).r;

	} else {

		gl_FragDepth = texture( depthColor, vec3( coord.x, coord.y, 0 ) ).r;

	}

}`,ml=class{constructor(){this.texture=null,this.mesh=null,this.depthNear=0,this.depthFar=0}init(e,t){if(this.texture===null){let n=new cr(e.texture);(e.depthNear!==t.depthNear||e.depthFar!==t.depthFar)&&(this.depthNear=e.depthNear,this.depthFar=e.depthFar),this.texture=n}}getMesh(e){if(this.texture!==null&&this.mesh===null){let t=e.cameras[0].viewport,n=new tn({vertexShader:mg,fragmentShader:Mg,uniforms:{depthColor:{value:this.texture},depthWidth:{value:t.z},depthHeight:{value:t.w}}});this.mesh=new Ct(new lr(20,20),n)}return this.mesh}reset(){this.texture=null,this.mesh=null}getDepthTexture(){return this.texture}},Ml=class extends Pn{constructor(e,t){super();let n=this,s=null,r=1,a=null,o="local-floor",c=1,l=null,h=null,f=null,u=null,d=null,g=null,y=typeof XRWebGLBinding<"u",m=new ml,p={},T=t.getContextAttributes(),R=null,v=null,b=[],S=[],A=new Oe,_=null,E=null,P=new xt;P.viewport=new et;let N=new xt;N.viewport=new et;let k=[P,N],H=new Na,L=null,V=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(q){let j=b[q];return j===void 0&&(j=new ps,b[q]=j),j.getTargetRaySpace()},this.getControllerGrip=function(q){let j=b[q];return j===void 0&&(j=new ps,b[q]=j),j.getGripSpace()},this.getHand=function(q){let j=b[q];return j===void 0&&(j=new ps,b[q]=j),j.getHandSpace()};function K(q){let j=S.indexOf(q.inputSource);if(j===-1)return;let ge=b[j];ge!==void 0&&(ge.update(q.inputSource,q.frame,l||a),ge.dispatchEvent({type:q.type,data:q.inputSource}))}function Z(){s.removeEventListener("select",K),s.removeEventListener("selectstart",K),s.removeEventListener("selectend",K),s.removeEventListener("squeeze",K),s.removeEventListener("squeezestart",K),s.removeEventListener("squeezeend",K),s.removeEventListener("end",Z),s.removeEventListener("inputsourceschange",ne);for(let q=0;q<b.length;q++){let j=S[q];j!==null&&(S[q]=null,b[q].disconnect(j))}L=null,V=null,m.reset();for(let q in p)delete p[q];if(e.setRenderTarget(R),d=null,u=null,f=null,s=null,v=null,Ze.stop(),n.isPresenting=!1,e.setPixelRatio(_),e.setSize(A.width,A.height,!1),E!==null){let q=E.camera;q.fov=E.fov,q.zoom=E.zoom,q.updateProjectionMatrix(),E=null}n.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(q){r=q,n.isPresenting===!0&&be("WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(q){o=q,n.isPresenting===!0&&be("WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return l||a},this.setReferenceSpace=function(q){l=q},this.getBaseLayer=function(){return u!==null?u:d},this.getBinding=function(){return f===null&&y&&(f=new XRWebGLBinding(s,t)),f},this.getFrame=function(){return g},this.getSession=function(){return s},this.setSession=async function(q){if(s=q,s!==null){if(R=e.getRenderTarget(),s.addEventListener("select",K),s.addEventListener("selectstart",K),s.addEventListener("selectend",K),s.addEventListener("squeeze",K),s.addEventListener("squeezestart",K),s.addEventListener("squeezeend",K),s.addEventListener("end",Z),s.addEventListener("inputsourceschange",ne),T.xrCompatible!==!0&&await t.makeXRCompatible(),_=e.getPixelRatio(),e.getSize(A),y&&"createProjectionLayer"in XRWebGLBinding.prototype){let ge=null,Pe=null,me=null;T.depth&&(me=T.stencil?t.DEPTH24_STENCIL8:t.DEPTH_COMPONENT24,ge=T.stencil?_i:In,Pe=T.stencil?Cs:Sn);let Be={colorFormat:t.RGBA8,depthFormat:me,scaleFactor:r};f=this.getBinding(),u=f.createProjectionLayer(Be),s.updateRenderState({layers:[u]}),e.setPixelRatio(1),e.setSize(u.textureWidth,u.textureHeight,!1),v=new Wt(u.textureWidth,u.textureHeight,{format:sn,type:Zt,depthTexture:new pi(u.textureWidth,u.textureHeight,Pe,void 0,void 0,void 0,void 0,void 0,void 0,ge),stencilBuffer:T.stencil,colorSpace:e.outputColorSpace,samples:T.antialias?4:0,resolveDepthBuffer:u.ignoreDepthValues===!1,resolveStencilBuffer:u.ignoreDepthValues===!1,storeMultisampledDepthBuffer:u.ignoreDepthValues===!1,storeMultisampledStencilBuffer:u.ignoreDepthValues===!1})}else{let ge={antialias:T.antialias,alpha:!0,depth:T.depth,stencil:T.stencil,framebufferScaleFactor:r};d=new XRWebGLLayer(s,t,ge),s.updateRenderState({baseLayer:d}),e.setPixelRatio(1),e.setSize(d.framebufferWidth,d.framebufferHeight,!1),v=new Wt(d.framebufferWidth,d.framebufferHeight,{format:sn,type:Zt,colorSpace:e.outputColorSpace,stencilBuffer:T.stencil,resolveDepthBuffer:d.ignoreDepthValues===!1,resolveStencilBuffer:d.ignoreDepthValues===!1,storeMultisampledDepthBuffer:d.ignoreDepthValues===!1,storeMultisampledStencilBuffer:d.ignoreDepthValues===!1})}v.isXRRenderTarget=!0,this.setFoveation(c),l=null,a=await s.requestReferenceSpace(o),Ze.setContext(s),Ze.start(),n.isPresenting=!0,n.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(s!==null)return s.environmentBlendMode},this.getDepthTexture=function(){return m.getDepthTexture()};function ne(q){for(let j=0;j<q.removed.length;j++){let ge=q.removed[j],Pe=S.indexOf(ge);Pe>=0&&(S[Pe]=null,b[Pe].disconnect(ge))}for(let j=0;j<q.added.length;j++){let ge=q.added[j],Pe=S.indexOf(ge);if(Pe===-1){for(let Be=0;Be<b.length;Be++)if(Be>=S.length){S.push(ge),Pe=Be;break}else if(S[Be]===null){S[Be]=ge,Pe=Be;break}if(Pe===-1)break}let me=b[Pe];me&&me.connect(ge)}}let X=new O,Q=new O;function te(q,j,ge){X.setFromMatrixPosition(j.matrixWorld),Q.setFromMatrixPosition(ge.matrixWorld);let Pe=X.distanceTo(Q),me=j.projectionMatrix.elements,Be=ge.projectionMatrix.elements,yt=me[14]/(me[10]-1),Ve=me[14]/(me[10]+1),Ye=(me[9]+1)/me[5],rt=(me[9]-1)/me[5],We=(me[8]-1)/me[0],lt=(Be[8]+1)/Be[0],Et=yt*We,Ht=yt*lt,ht=Pe/(-We+lt),Mt=ht*-We;if(j.matrixWorld.decompose(q.position,q.quaternion,q.scale),q.translateX(Mt),q.translateZ(ht),q.matrixWorld.compose(q.position,q.quaternion,q.scale),q.matrixWorldInverse.copy(q.matrixWorld).invert(),me[10]===-1)q.projectionMatrix.copy(j.projectionMatrix),q.projectionMatrixInverse.copy(j.projectionMatrixInverse);else{let I=yt+ht,zt=Ve+ht,je=Et-Mt,w=Ht+(Pe-Mt),M=Ye*Ve/zt*I,D=rt*Ve/zt*I;q.projectionMatrix.makePerspective(je,w,M,D,I,zt),q.projectionMatrixInverse.copy(q.projectionMatrix).invert()}}function Ae(q,j){j===null?q.matrixWorld.copy(q.matrix):q.matrixWorld.multiplyMatrices(j.matrixWorld,q.matrix),q.matrixWorldInverse.copy(q.matrixWorld).invert()}this.updateCamera=function(q){if(s===null)return;let j=q.near,ge=q.far;m.texture!==null&&(m.depthNear>0&&(j=m.depthNear),m.depthFar>0&&(ge=m.depthFar)),H.near=N.near=P.near=j,H.far=N.far=P.far=ge,(L!==H.near||V!==H.far)&&(s.updateRenderState({depthNear:H.near,depthFar:H.far}),L=H.near,V=H.far),H.layers.mask=q.layers.mask|6,P.layers.mask=H.layers.mask&-5,N.layers.mask=H.layers.mask&-3;let Pe=q.parent,me=H.cameras;Ae(H,Pe);for(let Be=0;Be<me.length;Be++)Ae(me[Be],Pe);me.length===2?te(H,P,N):H.projectionMatrix.copy(P.projectionMatrix),E===null&&q.isPerspectiveCamera&&(E={camera:q,fov:q.fov,zoom:q.zoom}),Te(q,H,Pe)};function Te(q,j,ge){ge===null?q.matrix.copy(j.matrixWorld):(q.matrix.copy(ge.matrixWorld),q.matrix.invert(),q.matrix.multiply(j.matrixWorld)),q.matrix.decompose(q.position,q.quaternion,q.scale),q.updateMatrixWorld(!0),q.projectionMatrix.copy(j.projectionMatrix),q.projectionMatrixInverse.copy(j.projectionMatrixInverse),q.isPerspectiveCamera&&(q.fov=Ii*2*Math.atan(1/q.projectionMatrix.elements[5]),q.zoom=1)}this.getCamera=function(){return H},this.getFoveation=function(){if(!(u===null&&d===null))return c},this.setFoveation=function(q){c=q,u!==null&&(u.fixedFoveation=q),d!==null&&d.fixedFoveation!==void 0&&(d.fixedFoveation=q)},this.hasDepthSensing=function(){return m.texture!==null},this.getDepthSensingMesh=function(){return m.getMesh(H)},this.getCameraTexture=function(q){return p[q]};let st=null;function Xe(q,j){if(h=j.getViewerPose(l||a),g=j,h!==null){let ge=h.views;d!==null&&(e.setRenderTargetFramebuffer(v,d.framebuffer),e.setRenderTarget(v));let Pe=!1;ge.length!==H.cameras.length&&(H.cameras.length=0,Pe=!0);for(let Ve=0;Ve<ge.length;Ve++){let Ye=ge[Ve],rt=null;if(d!==null)rt=d.getViewport(Ye);else{let lt=f.getViewSubImage(u,Ye);rt=lt.viewport,Ve===0&&(e.setRenderTargetTextures(v,lt.colorTexture,lt.depthStencilTexture),e.setRenderTarget(v))}let We=k[Ve];We===void 0&&(We=new xt,We.layers.enable(Ve),We.viewport=new et,k[Ve]=We),We.matrix.fromArray(Ye.transform.matrix),We.matrix.decompose(We.position,We.quaternion,We.scale),We.projectionMatrix.fromArray(Ye.projectionMatrix),We.projectionMatrixInverse.copy(We.projectionMatrix).invert(),We.viewport.set(rt.x,rt.y,rt.width,rt.height),Ve===0&&(H.matrix.copy(We.matrix),H.matrix.decompose(H.position,H.quaternion,H.scale)),Pe===!0&&H.cameras.push(We)}let me=s.enabledFeatures;if(me&&me.includes("depth-sensing")&&s.depthUsage=="gpu-optimized"&&y){f=n.getBinding();let Ve=f.getDepthInformation(ge[0]);Ve&&Ve.isValid&&Ve.texture&&m.init(Ve,s.renderState)}if(me&&me.includes("camera-access")&&y){e.state.unbindTexture(),f=n.getBinding();for(let Ve=0;Ve<ge.length;Ve++){let Ye=ge[Ve].camera;if(Ye){let rt=p[Ye];rt||(rt=new cr,p[Ye]=rt);let We=f.getCameraImage(Ye);rt.sourceTexture=We}}}}for(let ge=0;ge<b.length;ge++){let Pe=S[ge],me=b[ge];Pe!==null&&me!==void 0&&me.update(Pe,j,l||a)}st&&st(q,j),j.detectedPlanes&&n.dispatchEvent({type:"planesdetected",data:j}),g=null}let Ze=new ju;Ze.setAnimationLoop(Xe),this.setAnimationLoop=function(q){st=q},this.dispose=function(){}}},gg=new Ne,rf=new Ie;rf.set(-1,0,0,0,1,0,0,0,1);function _g(i,e){function t(m,p){m.matrixAutoUpdate===!0&&m.updateMatrix(),p.value.copy(m.matrix)}function n(m,p){p.color.getRGB(m.fogColor.value,jc(i)),p.isFog?(m.fogNear.value=p.near,m.fogFar.value=p.far):p.isFogExp2&&(m.fogDensity.value=p.density)}function s(m,p,T,R,v){p.isNodeMaterial?p.uniformsNeedUpdate=!1:p.isMeshBasicMaterial?r(m,p):p.isMeshLambertMaterial?(r(m,p),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)):p.isMeshToonMaterial?(r(m,p),f(m,p)):p.isMeshPhongMaterial?(r(m,p),h(m,p),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)):p.isMeshStandardMaterial?(r(m,p),u(m,p),p.isMeshPhysicalMaterial&&d(m,p,v)):p.isMeshMatcapMaterial?(r(m,p),g(m,p)):p.isMeshDepthMaterial?r(m,p):p.isMeshDistanceMaterial?(r(m,p),y(m,p)):p.isMeshNormalMaterial?r(m,p):p.isLineBasicMaterial?(a(m,p),p.isLineDashedMaterial&&o(m,p)):p.isPointsMaterial?c(m,p,T,R):p.isSpriteMaterial?l(m,p):p.isShadowMaterial?(m.color.value.copy(p.color),m.opacity.value=p.opacity):p.isShaderMaterial&&(p.uniformsNeedUpdate=!1)}function r(m,p){m.opacity.value=p.opacity,p.color&&m.diffuse.value.copy(p.color),p.emissive&&m.emissive.value.copy(p.emissive).multiplyScalar(p.emissiveIntensity),p.map&&(m.map.value=p.map,t(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,t(p.alphaMap,m.alphaMapTransform)),p.bumpMap&&(m.bumpMap.value=p.bumpMap,t(p.bumpMap,m.bumpMapTransform),m.bumpScale.value=p.bumpScale,p.side===Gt&&(m.bumpScale.value*=-1)),p.normalMap&&(m.normalMap.value=p.normalMap,t(p.normalMap,m.normalMapTransform),m.normalScale.value.copy(p.normalScale),p.side===Gt&&m.normalScale.value.negate()),p.displacementMap&&(m.displacementMap.value=p.displacementMap,t(p.displacementMap,m.displacementMapTransform),m.displacementScale.value=p.displacementScale,m.displacementBias.value=p.displacementBias),p.emissiveMap&&(m.emissiveMap.value=p.emissiveMap,t(p.emissiveMap,m.emissiveMapTransform)),p.specularMap&&(m.specularMap.value=p.specularMap,t(p.specularMap,m.specularMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest);let T=e.get(p),R=T.envMap,v=T.envMapRotation;R&&(m.envMap.value=R,m.envMapRotation.value.setFromMatrix4(gg.makeRotationFromEuler(v)).transpose(),R.isCubeTexture&&R.isRenderTargetTexture===!1&&m.envMapRotation.value.premultiply(rf),m.reflectivity.value=p.reflectivity,m.ior.value=p.ior,m.refractionRatio.value=p.refractionRatio),p.lightMap&&(m.lightMap.value=p.lightMap,m.lightMapIntensity.value=p.lightMapIntensity,t(p.lightMap,m.lightMapTransform)),p.aoMap&&(m.aoMap.value=p.aoMap,m.aoMapIntensity.value=p.aoMapIntensity,t(p.aoMap,m.aoMapTransform))}function a(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,p.map&&(m.map.value=p.map,t(p.map,m.mapTransform))}function o(m,p){m.dashSize.value=p.dashSize,m.totalSize.value=p.dashSize+p.gapSize,m.scale.value=p.scale}function c(m,p,T,R){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.size.value=p.size*T,m.scale.value=R*.5,p.map&&(m.map.value=p.map,t(p.map,m.uvTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,t(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function l(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.rotation.value=p.rotation,p.map&&(m.map.value=p.map,t(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,t(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function h(m,p){m.specular.value.copy(p.specular),m.shininess.value=Math.max(p.shininess,1e-4)}function f(m,p){p.gradientMap&&(m.gradientMap.value=p.gradientMap)}function u(m,p){m.metalness.value=p.metalness,p.metalnessMap&&(m.metalnessMap.value=p.metalnessMap,t(p.metalnessMap,m.metalnessMapTransform)),m.roughness.value=p.roughness,p.roughnessMap&&(m.roughnessMap.value=p.roughnessMap,t(p.roughnessMap,m.roughnessMapTransform)),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)}function d(m,p,T){m.ior.value=p.ior,p.sheen>0&&(m.sheenColor.value.copy(p.sheenColor).multiplyScalar(p.sheen),m.sheenRoughness.value=p.sheenRoughness,p.sheenColorMap&&(m.sheenColorMap.value=p.sheenColorMap,t(p.sheenColorMap,m.sheenColorMapTransform)),p.sheenRoughnessMap&&(m.sheenRoughnessMap.value=p.sheenRoughnessMap,t(p.sheenRoughnessMap,m.sheenRoughnessMapTransform))),p.clearcoat>0&&(m.clearcoat.value=p.clearcoat,m.clearcoatRoughness.value=p.clearcoatRoughness,p.clearcoatMap&&(m.clearcoatMap.value=p.clearcoatMap,t(p.clearcoatMap,m.clearcoatMapTransform)),p.clearcoatRoughnessMap&&(m.clearcoatRoughnessMap.value=p.clearcoatRoughnessMap,t(p.clearcoatRoughnessMap,m.clearcoatRoughnessMapTransform)),p.clearcoatNormalMap&&(m.clearcoatNormalMap.value=p.clearcoatNormalMap,t(p.clearcoatNormalMap,m.clearcoatNormalMapTransform),m.clearcoatNormalScale.value.copy(p.clearcoatNormalScale),p.side===Gt&&m.clearcoatNormalScale.value.negate())),p.dispersion>0&&(m.dispersion.value=p.dispersion),p.retroreflectivity>0&&(m.retroreflectivity.value=p.retroreflectivity),p.iridescence>0&&(m.iridescence.value=p.iridescence,m.iridescenceIOR.value=p.iridescenceIOR,m.iridescenceThicknessMinimum.value=p.iridescenceThicknessRange[0],m.iridescenceThicknessMaximum.value=p.iridescenceThicknessRange[1],p.iridescenceMap&&(m.iridescenceMap.value=p.iridescenceMap,t(p.iridescenceMap,m.iridescenceMapTransform)),p.iridescenceThicknessMap&&(m.iridescenceThicknessMap.value=p.iridescenceThicknessMap,t(p.iridescenceThicknessMap,m.iridescenceThicknessMapTransform))),p.transmission>0&&(m.transmission.value=p.transmission,m.transmissionSamplerMap.value=T.texture,m.transmissionSamplerSize.value.set(T.width,T.height),p.transmissionMap&&(m.transmissionMap.value=p.transmissionMap,t(p.transmissionMap,m.transmissionMapTransform)),m.thickness.value=p.thickness,p.thicknessMap&&(m.thicknessMap.value=p.thicknessMap,t(p.thicknessMap,m.thicknessMapTransform)),m.attenuationDistance.value=p.attenuationDistance,m.attenuationColor.value.copy(p.attenuationColor)),p.anisotropy>0&&(m.anisotropyVector.value.set(p.anisotropy*Math.cos(p.anisotropyRotation),p.anisotropy*Math.sin(p.anisotropyRotation)),p.anisotropyMap&&(m.anisotropyMap.value=p.anisotropyMap,t(p.anisotropyMap,m.anisotropyMapTransform))),m.specularIntensity.value=p.specularIntensity,m.specularColor.value.copy(p.specularColor),p.specularColorMap&&(m.specularColorMap.value=p.specularColorMap,t(p.specularColorMap,m.specularColorMapTransform)),p.specularIntensityMap&&(m.specularIntensityMap.value=p.specularIntensityMap,t(p.specularIntensityMap,m.specularIntensityMapTransform))}function g(m,p){p.matcap&&(m.matcap.value=p.matcap)}function y(m,p){let T=e.get(p).light;m.referencePosition.value.setFromMatrixPosition(T.matrixWorld),m.nearDistance.value=T.shadow.camera.near,m.farDistance.value=T.shadow.camera.far}return{refreshFogUniforms:n,refreshMaterialUniforms:s}}function xg(i,e,t,n){let s={},r={},a=[],o=i.getParameter(i.MAX_UNIFORM_BUFFER_BINDINGS);function c(v,b){let S=b.program;n.uniformBlockBinding(v,S)}function l(v,b){let S=s[v.id];S===void 0&&(m(v),S=h(v),s[v.id]=S,v.addEventListener("dispose",T));let A=b.program;n.updateUBOMapping(v,A);let _=e.render.frame;r[v.id]!==_&&(u(v),r[v.id]=_)}function h(v){let b=f();v.__bindingPointIndex=b;let S=i.createBuffer(),A=v.__size,_=v.usage;return i.bindBuffer(i.UNIFORM_BUFFER,S),i.bufferData(i.UNIFORM_BUFFER,A,_),i.bindBuffer(i.UNIFORM_BUFFER,null),i.bindBufferBase(i.UNIFORM_BUFFER,b,S),S}function f(){for(let v=0;v<o;v++)if(a.indexOf(v)===-1)return a.push(v),v;return ze("WebGLRenderer: Maximum number of simultaneously usable uniforms groups reached."),0}function u(v){let b=s[v.id],S=v.uniforms,A=v.__cache;i.bindBuffer(i.UNIFORM_BUFFER,b);for(let _=0,E=S.length;_<E;_++){let P=S[_];if(Array.isArray(P))for(let N=0,k=P.length;N<k;N++)d(P[N],_,N,A);else d(P,_,0,A)}i.bindBuffer(i.UNIFORM_BUFFER,null)}function d(v,b,S,A){if(y(v,b,S,A)===!0){let _=v.__offset,E=v.value;if(Array.isArray(E)){let P=0;for(let N=0;N<E.length;N++){let k=E[N],H=p(k);g(k,v.__data,P),typeof k!="number"&&typeof k!="boolean"&&!k.isMatrix3&&!ArrayBuffer.isView(k)&&(P+=H.storage/Float32Array.BYTES_PER_ELEMENT)}}else g(E,v.__data,0);i.bufferSubData(i.UNIFORM_BUFFER,_,v.__data)}}function g(v,b,S){typeof v=="number"||typeof v=="boolean"?b[0]=v:v.isMatrix3?(b[0]=v.elements[0],b[1]=v.elements[1],b[2]=v.elements[2],b[3]=0,b[4]=v.elements[3],b[5]=v.elements[4],b[6]=v.elements[5],b[7]=0,b[8]=v.elements[6],b[9]=v.elements[7],b[10]=v.elements[8],b[11]=0):ArrayBuffer.isView(v)?b.set(new v.constructor(v.buffer,v.byteOffset,b.length)):v.toArray(b,S)}function y(v,b,S,A){let _=v.value,E=b+"_"+S;if(A[E]===void 0)return typeof _=="number"||typeof _=="boolean"?A[E]=_:ArrayBuffer.isView(_)?A[E]=_.slice():A[E]=_.clone(),!0;{let P=A[E];if(typeof _=="number"||typeof _=="boolean"){if(P!==_)return A[E]=_,!0}else{if(ArrayBuffer.isView(_))return!0;if(P.equals(_)===!1)return P.copy(_),!0}}return!1}function m(v){let b=v.uniforms,S=0,A=16;for(let E=0,P=b.length;E<P;E++){let N=Array.isArray(b[E])?b[E]:[b[E]];for(let k=0,H=N.length;k<H;k++){let L=N[k],V=Array.isArray(L.value)?L.value:[L.value];for(let K=0,Z=V.length;K<Z;K++){let ne=V[K],X=p(ne),Q=S%A,te=Q%X.boundary,Ae=Q+te;S+=te,Ae!==0&&A-Ae<X.storage&&(S+=A-Ae),L.__data=new Float32Array(X.storage/Float32Array.BYTES_PER_ELEMENT),L.__offset=S,S+=X.storage}}}let _=S%A;return _>0&&(S+=A-_),v.__size=S,v.__cache={},this}function p(v){let b={boundary:0,storage:0};return typeof v=="number"||typeof v=="boolean"?(b.boundary=4,b.storage=4):v.isVector2?(b.boundary=8,b.storage=8):v.isVector3||v.isColor?(b.boundary=16,b.storage=12):v.isVector4?(b.boundary=16,b.storage=16):v.isMatrix3?(b.boundary=48,b.storage=48):v.isMatrix4?(b.boundary=64,b.storage=64):v.isTexture?be("WebGLRenderer: Texture samplers can not be part of an uniforms group."):ArrayBuffer.isView(v)?(b.boundary=16,b.storage=v.byteLength):be("WebGLRenderer: Unsupported uniform value type.",v),b}function T(v){let b=v.target;b.removeEventListener("dispose",T);let S=a.indexOf(b.__bindingPointIndex);a.splice(S,1),i.deleteBuffer(s[b.id]),delete s[b.id],delete r[b.id]}function R(){for(let v in s)i.deleteBuffer(s[v]);a=[],s={},r={}}return{bind:c,update:l,dispose:R}}var yg=new Uint16Array([12469,15057,12620,14925,13266,14620,13807,14376,14323,13990,14545,13625,14713,13328,14840,12882,14931,12528,14996,12233,15039,11829,15066,11525,15080,11295,15085,10976,15082,10705,15073,10495,13880,14564,13898,14542,13977,14430,14158,14124,14393,13732,14556,13410,14702,12996,14814,12596,14891,12291,14937,11834,14957,11489,14958,11194,14943,10803,14921,10506,14893,10278,14858,9960,14484,14039,14487,14025,14499,13941,14524,13740,14574,13468,14654,13106,14743,12678,14818,12344,14867,11893,14889,11509,14893,11180,14881,10751,14852,10428,14812,10128,14765,9754,14712,9466,14764,13480,14764,13475,14766,13440,14766,13347,14769,13070,14786,12713,14816,12387,14844,11957,14860,11549,14868,11215,14855,10751,14825,10403,14782,10044,14729,9651,14666,9352,14599,9029,14967,12835,14966,12831,14963,12804,14954,12723,14936,12564,14917,12347,14900,11958,14886,11569,14878,11247,14859,10765,14828,10401,14784,10011,14727,9600,14660,9289,14586,8893,14508,8533,15111,12234,15110,12234,15104,12216,15092,12156,15067,12010,15028,11776,14981,11500,14942,11205,14902,10752,14861,10393,14812,9991,14752,9570,14682,9252,14603,8808,14519,8445,14431,8145,15209,11449,15208,11451,15202,11451,15190,11438,15163,11384,15117,11274,15055,10979,14994,10648,14932,10343,14871,9936,14803,9532,14729,9218,14645,8742,14556,8381,14461,8020,14365,7603,15273,10603,15272,10607,15267,10619,15256,10631,15231,10614,15182,10535,15118,10389,15042,10167,14963,9787,14883,9447,14800,9115,14710,8665,14615,8318,14514,7911,14411,7507,14279,7198,15314,9675,15313,9683,15309,9712,15298,9759,15277,9797,15229,9773,15166,9668,15084,9487,14995,9274,14898,8910,14800,8539,14697,8234,14590,7790,14479,7409,14367,7067,14178,6621,15337,8619,15337,8631,15333,8677,15325,8769,15305,8871,15264,8940,15202,8909,15119,8775,15022,8565,14916,8328,14804,8009,14688,7614,14569,7287,14448,6888,14321,6483,14088,6171,15350,7402,15350,7419,15347,7480,15340,7613,15322,7804,15287,7973,15229,8057,15148,8012,15046,7846,14933,7611,14810,7357,14682,7069,14552,6656,14421,6316,14251,5948,14007,5528,15356,5942,15356,5977,15353,6119,15348,6294,15332,6551,15302,6824,15249,7044,15171,7122,15070,7050,14949,6861,14818,6611,14679,6349,14538,6067,14398,5651,14189,5311,13935,4958,15359,4123,15359,4153,15356,4296,15353,4646,15338,5160,15311,5508,15263,5829,15188,6042,15088,6094,14966,6001,14826,5796,14678,5543,14527,5287,14377,4985,14133,4586,13869,4257,15360,1563,15360,1642,15358,2076,15354,2636,15341,3350,15317,4019,15273,4429,15203,4732,15105,4911,14981,4932,14836,4818,14679,4621,14517,4386,14359,4156,14083,3795,13808,3437,15360,122,15360,137,15358,285,15355,636,15344,1274,15322,2177,15281,2765,15215,3223,15120,3451,14995,3569,14846,3567,14681,3466,14511,3305,14344,3121,14037,2800,13753,2467,15360,0,15360,1,15359,21,15355,89,15346,253,15325,479,15287,796,15225,1148,15133,1492,15008,1749,14856,1882,14685,1886,14506,1783,14324,1608,13996,1398,13702,1183]),Fn=null;function vg(){return Fn===null&&(Fn=new _s(yg,16,16,xi,wn),Fn.name="DFG_LUT",Fn.minFilter=pt,Fn.magFilter=pt,Fn.wrapS=cn,Fn.wrapT=cn,Fn.generateMipmaps=!1,Fn.needsUpdate=!0),Fn}var Co=class{constructor(e={}){let{canvas:t=Su(),context:n=null,depth:s=!0,stencil:r=!1,alpha:a=!1,antialias:o=!1,premultipliedAlpha:c=!0,preserveDrawingBuffer:l=!1,powerPreference:h="default",failIfMajorPerformanceCaveat:f=!1,reversedDepthBuffer:u=!1,outputBufferType:d=Zt}=e;this.isWebGLRenderer=!0;let g;if(n!==null){if(typeof WebGLRenderingContext<"u"&&n instanceof WebGLRenderingContext)throw new Error("THREE.WebGLRenderer: WebGL 1 is not supported since r163.");g=n.getContextAttributes().alpha}else g=a;let y=d,m=new Set([Xa,Wa,Ha]),p=new Set([Zt,Sn,Rs,Cs,ka,Va]),T=new Uint32Array(4),R=new Int32Array(4),v=new O,b=null,S=null,A=[],_=[],E=null;this.domElement=t,this.debug={checkShaderErrors:!0,diagnostics:{keywords:!1},onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this.toneMapping=vn,this.toneMappingExposure=1,this.transmissionResolutionScale=1;let P=this,N=!1,k=null,H=null,L=null,V=null;this._outputColorSpace=vt;let K=0,Z=0,ne=null,X=-1,Q=null,te=new et,Ae=new et,Te=null,st=new Ce(0),Xe=0,Ze=t.width,q=t.height,j=1,ge=null,Pe=null,me=new et(0,0,Ze,q),Be=new et(0,0,Ze,q),yt=!1,Ve=new xs,Ye=!1,rt=!1,We=new Ne,lt=new O,Et=new et,Ht={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0},ht=!1;function Mt(){return ne===null?j:1}let I=n;function zt(x,C){return t.getContext(x,C)}let je,w,M,D,B,W,ie,se,Y,$,re,Se,le,ae,we,Re,Le,z,oe,J,ce,de,ee;try{let x={alpha:!0,depth:s,stencil:r,antialias:o,premultipliedAlpha:c,preserveDrawingBuffer:l,powerPreference:h,failIfMajorPerformanceCaveat:f};if("setAttribute"in t&&t.setAttribute("data-engine",`three.js r${"186"}`),t.addEventListener("webglcontextlost",at,!1),t.addEventListener("webglcontextrestored",Ke,!1),t.addEventListener("webglcontextcreationerror",fn,!1),I===null){let C="webgl2";if(I=zt(C,x),I===null)throw zt(C)?new Error("THREE.WebGLRenderer: Error creating WebGL context with your selected attributes."):new Error("THREE.WebGLRenderer: Error creating WebGL context.")}Ee()}catch(x){throw t.removeEventListener("webglcontextlost",at,!1),t.removeEventListener("webglcontextrestored",Ke,!1),t.removeEventListener("webglcontextcreationerror",fn,!1),ze("WebGLRenderer: "+x.message),x}function Ee(){je=new Rm(I),je.init(),ce=new pg(I,je),w=new _m(I,je,e,ce),M=new fg(I,je),w.reversedDepthBuffer&&u&&M.buffers.depth.setReversed(!0),H=I.createFramebuffer(),L=I.createFramebuffer(),V=I.createFramebuffer(),D=new Im(I),B=new jM,W=new dg(I,je,M,B,w,ce,D),ie=new Am(P),se=new Ld(I),de=new Mm(I,se),Y=new Cm(I,se,D,de),$=new Lm(I,Y,se,de,D),z=new Pm(I,w,W),we=new xm(B),re=new $M(P,ie,je,w,de,we),Se=new _g(P,B),le=new eg,ae=new ag(je),Le=new mm(P,ie,M,$,g,c),Re=new ug(P,$,w),ee=new xg(I,D,w,M),oe=new gm(I,je,D),J=new zm(I,je,D),D.programs=re.programs,P.capabilities=w,P.extensions=je,P.properties=B,P.renderLists=le,P.shadowMap=Re,P.state=M,P.info=D}y!==Zt&&(E=new Dm(y,t.width,t.height,o,s,r));let ye=new Ml(P,I);this.xr=ye,this.getContext=function(){return I},this.getContextAttributes=function(){return I.getContextAttributes()},this.forceContextLoss=function(){let x=je.get("WEBGL_lose_context");x&&x.loseContext()},this.forceContextRestore=function(){let x=je.get("WEBGL_lose_context");x&&x.restoreContext()},this.getPixelRatio=function(){return j},this.setPixelRatio=function(x){x!==void 0&&(j=x,this.setSize(Ze,q,!1))},this.getSize=function(x){return x.set(Ze,q)},this.setSize=function(x,C,G=!0){if(ye.isPresenting){be("WebGLRenderer: Can't change size while VR device is presenting.");return}Ze=x,q=C,t.width=Math.floor(x*j),t.height=Math.floor(C*j),G===!0&&(t.style.width=x+"px",t.style.height=C+"px"),E!==null&&E.setSize(t.width,t.height),this.setViewport(0,0,x,C)},this.getDrawingBufferSize=function(x){return x.set(Ze*j,q*j).floor()},this.setDrawingBufferSize=function(x,C,G){Ze=x,q=C,j=G,t.width=Math.floor(x*G),t.height=Math.floor(C*G),this.setViewport(0,0,x,C)},this.setEffects=function(x){if(y===Zt){ze("WebGLRenderer: setEffects() requires outputBufferType set to HalfFloatType or FloatType.");return}if(x){for(let C=0;C<x.length;C++)if(x[C].isOutputPass===!0){be("WebGLRenderer: OutputPass is not needed in setEffects(). Tone mapping and color space conversion are applied automatically.");break}}E.setEffects(x||[])},this.getCurrentViewport=function(x){return x.copy(te)},this.getViewport=function(x){return x.copy(me)},this.setViewport=function(x,C,G,U){x.isVector4?me.set(x.x,x.y,x.z,x.w):me.set(x,C,G,U),M.viewport(te.copy(me).multiplyScalar(j).round())},this.getScissor=function(x){return x.copy(Be)},this.setScissor=function(x,C,G,U){x.isVector4?Be.set(x.x,x.y,x.z,x.w):Be.set(x,C,G,U),M.scissor(Ae.copy(Be).multiplyScalar(j).round())},this.getScissorTest=function(){return yt},this.setScissorTest=function(x){M.setScissorTest(yt=x)},this.setOpaqueSort=function(x){ge=x},this.setTransparentSort=function(x){Pe=x},this.getClearColor=function(x){return x.copy(Le.getClearColor())},this.setClearColor=function(){Le.setClearColor(...arguments)},this.getClearAlpha=function(){return Le.getClearAlpha()},this.setClearAlpha=function(){Le.setClearAlpha(...arguments)},this.clear=function(x=!0,C=!0,G=!0){let U=0;if(x){let F=!1;if(ne!==null){let fe=ne.texture.format;F=m.has(fe)}if(F){let fe=ne.texture.type,Me=p.has(fe),ue=Le.getClearColor(),_e=Le.getClearAlpha(),ve=ue.r,De=ue.g,Ge=ue.b;Me?(T[0]=ve,T[1]=De,T[2]=Ge,T[3]=_e,I.clearBufferuiv(I.COLOR,0,T)):(R[0]=ve,R[1]=De,R[2]=Ge,R[3]=_e,I.clearBufferiv(I.COLOR,0,R))}else U|=I.COLOR_BUFFER_BIT}C&&(U|=I.DEPTH_BUFFER_BIT,this.state.buffers.depth.setMask(!0)),G&&(U|=I.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),U!==0&&I.clear(U)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.setNodesHandler=function(x){x.setRenderer(this),k=x},this.dispose=function(){t.removeEventListener("webglcontextlost",at,!1),t.removeEventListener("webglcontextrestored",Ke,!1),t.removeEventListener("webglcontextcreationerror",fn,!1),Le.dispose(),le.dispose(),ae.dispose(),B.dispose(),ie.dispose(),$.dispose(),de.dispose(),ee.dispose(),re.dispose(),ye.dispose(),ye.removeEventListener("sessionstart",$l),ye.removeEventListener("sessionend",jl),Si.stop()};function at(x){x.preventDefault(),Ks("WebGLRenderer: Context Lost."),N=!0}function Ke(){Ks("WebGLRenderer: Context Restored."),N=!1;let x=D.autoReset,C=Re.enabled,G=Re.autoUpdate,U=Re.needsUpdate,F=Re.type;Ee(),D.autoReset=x,Re.enabled=C,Re.autoUpdate=G,Re.needsUpdate=U,Re.type=F}function fn(x){ze("WebGLRenderer: A WebGL context could not be created. Reason: ",x.statusMessage)}function An(x){let C=x.target;C.removeEventListener("dispose",An),bf(C)}function bf(x){Sf(x),B.remove(x)}function Sf(x){let C=B.get(x).programs;C!==void 0&&(C.forEach(function(G){re.releaseProgram(G)}),x.isShaderMaterial&&re.releaseShaderCache(x))}this.renderBufferDirect=function(x,C,G,U,F,fe){C===null&&(C=Ht);let Me=F.isMesh&&F.matrixWorld.determinantAffine()<0,ue=Ef(x,C,G,U,F);M.setMaterial(U,Me);let _e=G.index,ve=1;if(U.wireframe===!0){if(_e=Y.getWireframeAttribute(G),_e===void 0)return;ve=2}let De=G.drawRange,Ge=G.attributes.position,xe=De.start*ve,Je=(De.start+De.count)*ve;fe!==null&&(xe=Math.max(xe,fe.start*ve),Je=Math.min(Je,(fe.start+fe.count)*ve)),_e!==null?(xe=Math.max(xe,0),Je=Math.min(Je,_e.count)):Ge!=null&&(xe=Math.max(xe,0),Je=Math.min(Je,Ge.count));let gt=Je-xe;if(gt<0||gt===1/0)return;de.setup(F,U,ue,G,_e);let ct,nt=oe;if(_e!==null&&(ct=se.get(_e),nt=J,nt.setIndex(ct)),F.isMesh)U.wireframe===!0?(M.setLineWidth(U.wireframeLinewidth*Mt()),nt.setMode(I.LINES)):nt.setMode(I.TRIANGLES);else if(F.isLine){let It=U.linewidth;It===void 0&&(It=1),M.setLineWidth(It*Mt()),F.isLineSegments?nt.setMode(I.LINES):F.isLineLoop?nt.setMode(I.LINE_LOOP):nt.setMode(I.LINE_STRIP)}else F.isPoints?nt.setMode(I.POINTS):F.isSprite&&nt.setMode(I.TRIANGLES);if(F.isBatchedMesh)if(je.get("WEBGL_multi_draw"))nt.renderMultiDraw(F._multiDrawStarts,F._multiDrawCounts,F._multiDrawCount);else{let It=F._multiDrawStarts,pe=F._multiDrawCounts,Ut=F._multiDrawCount,qe=_e?se.get(_e).bytesPerElement:1,an=B.get(U).currentProgram.getUniforms();for(let Rn=0;Rn<Ut;Rn++)an.setValue(I,"_gl_DrawID",Rn),nt.render(It[Rn]/qe,pe[Rn])}else if(F.isInstancedMesh)nt.renderInstances(xe,gt,F.count);else if(G.isInstancedBufferGeometry){let It=G._maxInstanceCount!==void 0?G._maxInstanceCount:1/0,pe=Math.min(G.instanceCount,It);nt.renderInstances(xe,gt,pe)}else nt.render(xe,gt)};function Jl(x,C,G,U){k!==null&&x.isNodeMaterial&&k.setObject(U,x),Ye===!0&&we.setState(x,G,!1),x.transparent===!0&&x.side===hn&&x.forceSinglePass===!1?(x.side=Gt,x.needsUpdate=!0,Dr(x,C,U),x.side=On,x.needsUpdate=!0,Dr(x,C,U),x.side=hn):Dr(x,C,U)}this.compile=function(x,C,G=null){G===null&&(G=x),k!==null&&k.renderStart(x,C,G),S=ae.get(G),S.init(C),_.push(S),G.traverseVisible(function(F){F.isLight&&F.layers.test(C.layers)&&(S.pushLight(F),F.castShadow&&S.pushShadow(F))}),x!==G&&x.traverseVisible(function(F){F.isLight&&F.layers.test(C.layers)&&(S.pushLight(F),F.castShadow&&S.pushShadow(F))}),S.setupLights(),k!==null&&k.updateLights(S.state.lightsArray),rt=this.localClippingEnabled,Ye=we.init(this.clippingPlanes,rt),Ye===!0&&we.setGlobalState(this.clippingPlanes,C),k!==null&&Re.render(S.state.shadowsArray,G,C);let U=new Set;return x.traverse(function(F){if(!(F.isMesh||F.isPoints||F.isLine||F.isSprite))return;let fe=F.material;if(fe)if(Array.isArray(fe))for(let Me=0;Me<fe.length;Me++){let ue=fe[Me];Jl(ue,G,C,F),U.add(ue)}else Jl(fe,G,C,F),U.add(fe)}),S=_.pop(),k!==null&&k.renderEnd(),U},this.compileAsync=function(x,C,G=null){let U=this.compile(x,C,G);return new Promise(F=>{function fe(){if(U.forEach(function(Me){let _e=B.get(Me).currentProgram;(_e===void 0||_e.isReady())&&U.delete(Me)}),U.size===0){F(x);return}setTimeout(fe,10)}je.get("KHR_parallel_shader_compile")!==null?fe():setTimeout(fe,10)})};let Wo=null;function wf(x){Wo&&Wo(x)}function $l(){Si.stop()}function jl(){Si.start()}let Si=new ju;Si.setAnimationLoop(wf),typeof self<"u"&&Si.setContext(self),this.setAnimationLoop=function(x){Wo=x,ye.setAnimationLoop(x),x===null?Si.stop():Si.start()},ye.addEventListener("sessionstart",$l),ye.addEventListener("sessionend",jl),this.render=function(x,C){if(C!==void 0&&C.isCamera!==!0){ze("WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(N===!0)return;k!==null&&k.renderStart(x,C);let G=ye.enabled===!0&&ye.isPresenting===!0,U=E!==null&&(ne===null||G)&&E.begin(P,ne);if(x.matrixWorldAutoUpdate===!0&&x.updateMatrixWorld(),C.parent===null&&C.matrixWorldAutoUpdate===!0&&C.updateMatrixWorld(),ye.enabled===!0&&ye.isPresenting===!0&&(E===null||E.isCompositing()===!1)&&(ye.cameraAutoUpdate===!0&&ye.updateCamera(C),C=ye.getCamera()),x.isScene===!0&&x.onBeforeRender(P,x,C,ne),S=ae.get(x,_.length),S.init(C),S.state.textureUnits=W.getTextureUnits(),_.push(S),We.multiplyMatrices(C.projectionMatrix,C.matrixWorldInverse),Ve.setFromProjectionMatrix(We,_n,C.reversedDepth),rt=this.localClippingEnabled,Ye=we.init(this.clippingPlanes,rt),b=le.get(x,A.length),b.init(),A.push(b),ye.enabled===!0&&ye.isPresenting===!0){let Me=P.xr.getDepthSensingMesh();Me!==null&&Xo(Me,C,-1/0,P.sortObjects)}Xo(x,C,0,P.sortObjects),b.finish(),k!==null&&k.updateLights(S.state.lightsArray),P.sortObjects===!0&&b.sort(ge,Pe),ht=ye.enabled===!1||ye.isPresenting===!1||ye.hasDepthSensing()===!1,ht&&Le.addToRenderList(b,x),this.info.render.frame++,this.info.autoReset===!0&&this.info.reset(),Ye===!0&&we.beginShadows();let F=S.state.shadowsArray;if(Re.render(F,x,C),Ye===!0&&we.endShadows(),(U&&E.hasRenderPass())===!1){let Me=b.opaque,ue=b.transmissive;if(S.setupLights(),C.isArrayCamera){let _e=C.cameras;if(ue.length>0)for(let ve=0,De=_e.length;ve<De;ve++){let Ge=_e[ve];eh(Me,ue,x,Ge)}ht&&Le.render(x);for(let ve=0,De=_e.length;ve<De;ve++){let Ge=_e[ve];Ql(b,x,Ge,Ge.viewport)}}else ue.length>0&&eh(Me,ue,x,C),ht&&Le.render(x),Ql(b,x,C)}ne!==null&&Z===0&&(W.updateMultisampleRenderTarget(ne),W.updateRenderTargetMipmap(ne)),U&&E.end(P),x.isScene===!0&&x.onAfterRender(P,x,C),de.resetDefaultState(),X=-1,Q=null,_.pop(),_.length>0?(S=_[_.length-1],W.setTextureUnits(S.state.textureUnits),Ye===!0&&we.setGlobalState(P.clippingPlanes,S.state.camera)):S=null,A.pop(),A.length>0?b=A[A.length-1]:b=null,k!==null&&k.renderEnd()};function Xo(x,C,G,U){if(x.visible===!1)return;if(x.layers.test(C.layers)){if(x.isGroup)G=x.renderOrder;else if(x.isLOD)x.autoUpdate===!0&&x.update(C);else if(x.isLightProbeGrid)S.pushLightProbeGrid(x);else if(x.isLight)S.pushLight(x),x.castShadow&&S.pushShadow(x);else if(x.isSprite){if(!x.frustumCulled||x.intersectsFrustum(Ve)){U&&Et.setFromMatrixPosition(x.matrixWorld).applyMatrix4(We);let Me=$.update(x),ue=x.material;ue.visible&&b.push(x,Me,ue,G,Et.z,null,C)}}else if((x.isMesh||x.isLine||x.isPoints)&&(!x.frustumCulled||x.intersectsFrustum(Ve))){let Me=$.update(x),ue=x.material;if(U&&(x.boundingSphere!==void 0?(x.boundingSphere===null&&x.computeBoundingSphere(),Et.copy(x.boundingSphere.center)):(Me.boundingSphere===null&&Me.computeBoundingSphere(),Et.copy(Me.boundingSphere.center)),Et.applyMatrix4(x.matrixWorld).applyMatrix4(We)),Array.isArray(ue)){let _e=Me.groups;for(let ve=0,De=_e.length;ve<De;ve++){let Ge=_e[ve],xe=ue[Ge.materialIndex];xe&&xe.visible&&b.push(x,Me,xe,G,Et.z,Ge,C)}}else ue.visible&&b.push(x,Me,ue,G,Et.z,null,C)}}let fe=x.children;for(let Me=0,ue=fe.length;Me<ue;Me++)Xo(fe[Me],C,G,U)}function Ql(x,C,G,U){let{opaque:F,transmissive:fe,transparent:Me}=x;S.setupLightsView(G),Ye===!0&&we.setGlobalState(P.clippingPlanes,G),U&&M.viewport(te.copy(U)),F.length>0&&Nr(F,C,G),fe.length>0&&Nr(fe,C,G),Me.length>0&&Nr(Me,C,G),M.buffers.depth.setTest(!0),M.buffers.depth.setMask(!0),M.buffers.color.setMask(!0),M.setPolygonOffset(!1)}function eh(x,C,G,U){if((G.isScene===!0?G.overrideMaterial:null)!==null)return;if(S.state.transmissionRenderTarget[U.id]===void 0){let xe=je.has("EXT_color_buffer_half_float")||je.has("EXT_color_buffer_float");S.state.transmissionRenderTarget[U.id]=new Wt(1,1,{generateMipmaps:!0,type:xe?wn:Zt,minFilter:bn,samples:Math.max(4,w.samples),stencilBuffer:r,resolveDepthBuffer:!1,resolveStencilBuffer:!1,storeMultisampledDepthBuffer:!1,storeMultisampledStencilBuffer:!1,colorSpace:Fe.workingColorSpace})}let fe=S.state.transmissionRenderTarget[U.id],Me=U.viewport||te;fe.setSize(Me.z*P.transmissionResolutionScale,Me.w*P.transmissionResolutionScale);let ue=P.getRenderTarget(),_e=P.getActiveCubeFace(),ve=P.getActiveMipmapLevel();P.setRenderTarget(fe),P.getClearColor(st),Xe=P.getClearAlpha(),Xe<1&&P.setClearColor(16777215,.5),P.clear(),ht&&Le.render(G);let De=P.toneMapping;P.toneMapping=vn;let Ge=U.viewport;if(U.viewport!==void 0&&(U.viewport=void 0),S.setupLightsView(U),Ye===!0&&we.setGlobalState(P.clippingPlanes,U),Nr(x,G,U),W.updateMultisampleRenderTarget(fe),W.updateRenderTargetMipmap(fe),je.has("WEBGL_multisampled_render_to_texture")===!1){let xe=!1;for(let Je=0,gt=C.length;Je<gt;Je++){let ct=C[Je],{object:nt,geometry:It,material:pe,group:Ut}=ct;if(pe.side===hn&&nt.layers.test(U.layers)){let qe=pe.side;pe.side=Gt,pe.needsUpdate=!0,th(nt,G,U,It,pe,Ut),pe.side=qe,pe.needsUpdate=!0,xe=!0}}xe===!0&&(W.updateMultisampleRenderTarget(fe),W.updateRenderTargetMipmap(fe))}P.setRenderTarget(ue,_e,ve),P.setClearColor(st,Xe),Ge!==void 0&&(U.viewport=Ge),P.toneMapping=De}function Nr(x,C,G){let U=C.isScene===!0?C.overrideMaterial:null;for(let F=0,fe=x.length;F<fe;F++){let Me=x[F],{object:ue,geometry:_e,group:ve}=Me,De=Me.material;De.allowOverride===!0&&U!==null&&(De=U),ue.layers.test(G.layers)&&th(ue,C,G,_e,De,ve)}}function th(x,C,G,U,F,fe){k!==null&&F.isNodeMaterial&&k.setObject(x,F),x.onBeforeRender(P,C,G,U,F,fe),x.modelViewMatrix.multiplyMatrices(G.matrixWorldInverse,x.matrixWorld),x.normalMatrix.getNormalMatrix(x.modelViewMatrix),F.onBeforeRender(P,C,G,U,x,fe),F.transparent===!0&&F.side===hn&&F.forceSinglePass===!1?(F.side=Gt,F.needsUpdate=!0,P.renderBufferDirect(G,C,U,F,x,fe),F.side=On,F.needsUpdate=!0,P.renderBufferDirect(G,C,U,F,x,fe),F.side=hn):P.renderBufferDirect(G,C,U,F,x,fe),x.onAfterRender(P,C,G,U,F,fe)}function Dr(x,C,G){C.isScene!==!0&&(C=Ht);let U=B.get(x),F=S.state.lights,fe=S.state.shadowsArray,Me=F.state.version,ue=re.getParameters(x,F.state,fe,C,G,S.state.lightProbeGridArray),_e=re.getProgramCacheKey(ue),ve=U.programs;U.environment=x.isMeshStandardMaterial||x.isMeshLambertMaterial||x.isMeshPhongMaterial?C.environment:null,U.fog=C.fog;let De=x.isMeshStandardMaterial||x.isMeshLambertMaterial&&!x.envMap||x.isMeshPhongMaterial&&!x.envMap;U.envMap=ie.get(x.envMap||U.environment,De),U.envMapRotation=U.environment!==null&&x.envMap===null?C.environmentRotation:x.envMapRotation,ve===void 0&&(x.addEventListener("dispose",An),ve=new Map,U.programs=ve);let Ge=ve.get(_e);if(Ge!==void 0){if(U.currentProgram===Ge&&U.lightsStateVersion===Me)return ih(x,ue),Ge}else ue.uniforms=re.getUniforms(x),k!==null&&x.isNodeMaterial&&k.build(x,G,ue),x.onBeforeCompile(ue,P),Ge=re.acquireProgram(ue,_e),ve.set(_e,Ge),U.uniforms=ue.uniforms;let xe=U.uniforms;return(!x.isShaderMaterial&&!x.isRawShaderMaterial||x.clipping===!0)&&(xe.clippingPlanes=we.uniform),ih(x,ue),U.needsLights=Rf(x),U.lightsStateVersion=Me,U.needsLights&&(xe.ambientLightColor.value=F.state.ambient,xe.lightProbe.value=F.state.probe,xe.sunLights.value=F.state.sun,xe.sunLightShadows.value=F.state.sunShadow,xe.directionalLights.value=F.state.directional,xe.directionalLightShadows.value=F.state.directionalShadow,xe.spotLights.value=F.state.spot,xe.spotLightShadows.value=F.state.spotShadow,xe.rectAreaLights.value=F.state.rectArea,xe.ltc_1.value=F.state.rectAreaLTC1,xe.ltc_2.value=F.state.rectAreaLTC2,xe.pointLights.value=F.state.point,xe.pointLightShadows.value=F.state.pointShadow,xe.hemisphereLights.value=F.state.hemi,xe.sunShadowMatrix.value=F.state.sunShadowMatrix,xe.sunShadowCascade.value=F.state.sunShadowCascade,xe.directionalShadowMatrix.value=F.state.directionalShadowMatrix,xe.spotLightMatrix.value=F.state.spotLightMatrix,xe.spotLightMap.value=F.state.spotLightMap,xe.pointShadowMatrix.value=F.state.pointShadowMatrix),U.lightProbeGrid=S.state.lightProbeGridArray.length>0,U.currentProgram=Ge,U.uniformsList=null,Ge}function nh(x){if(x.uniformsList===null){let C=x.currentProgram.getUniforms();x.uniformsList=Ls.seqWithValue(C.seq,x.uniforms)}return x.uniformsList}function ih(x,C){let G=B.get(x);G.outputColorSpace=C.outputColorSpace,G.batching=C.batching,G.batchingColor=C.batchingColor,G.instancing=C.instancing,G.instancingColor=C.instancingColor,G.instancingMorph=C.instancingMorph,G.skinning=C.skinning,G.morphTargets=C.morphTargets,G.morphNormals=C.morphNormals,G.morphColors=C.morphColors,G.morphTargetsCount=C.morphTargetsCount,G.numClippingPlanes=C.numClippingPlanes,G.numIntersection=C.numClipIntersection,G.vertexAlphas=C.vertexAlphas,G.vertexTangents=C.vertexTangents,G.toneMapping=C.toneMapping}function Tf(x,C){if(x.length===0)return null;if(x.length===1)return x[0].texture!==null?x[0]:null;v.setFromMatrixPosition(C.matrixWorld);for(let G=0,U=x.length;G<U;G++){let F=x[G];if(F.texture!==null&&F.boundingBox.containsPoint(v))return F}return null}function Ef(x,C,G,U,F){C.isScene!==!0&&(C=Ht),W.resetTextureUnits();let fe=C.fog,Me=U.isMeshStandardMaterial||U.isMeshLambertMaterial||U.isMeshPhongMaterial?C.environment:null,ue=ne===null?P.outputColorSpace:ne.isXRRenderTarget===!0?ne.texture.colorSpace:Fe.workingColorSpace,_e=U.isMeshStandardMaterial||U.isMeshLambertMaterial&&!U.envMap||U.isMeshPhongMaterial&&!U.envMap,ve=ie.get(U.envMap||Me,_e),De=U.vertexColors===!0&&!!G.attributes.color&&G.attributes.color.itemSize===4,Ge=!!G.attributes.tangent&&(!!U.normalMap||U.anisotropy>0),xe=!!G.morphAttributes.position,Je=!!G.morphAttributes.normal,gt=!!G.morphAttributes.color,ct=vn;U.toneMapped&&(ne===null||ne.isXRRenderTarget===!0)&&(ct=P.toneMapping);let nt=G.morphAttributes.position||G.morphAttributes.normal||G.morphAttributes.color,It=nt!==void 0?nt.length:0,pe=B.get(U),Ut=S.state.lights;if(Ye===!0&&(rt===!0||x!==Q)){let ot=x===Q&&U.id===X;we.setState(U,x,ot)}let qe=!1;U.version===pe.__version?(pe.needsLights&&pe.lightsStateVersion!==Ut.state.version||pe.outputColorSpace!==ue||F.isBatchedMesh&&pe.batching===!1||!F.isBatchedMesh&&pe.batching===!0||F.isBatchedMesh&&pe.batchingColor===!0&&F._colorsTexture===null||F.isBatchedMesh&&pe.batchingColor===!1&&F._colorsTexture!==null||F.isInstancedMesh&&pe.instancing===!1||!F.isInstancedMesh&&pe.instancing===!0||F.isSkinnedMesh&&pe.skinning===!1||!F.isSkinnedMesh&&pe.skinning===!0||F.isInstancedMesh&&pe.instancingColor===!0&&F.instanceColor===null||F.isInstancedMesh&&pe.instancingColor===!1&&F.instanceColor!==null||F.isInstancedMesh&&pe.instancingMorph===!0&&F.morphTexture===null||F.isInstancedMesh&&pe.instancingMorph===!1&&F.morphTexture!==null||pe.envMap!==ve||U.fog===!0&&pe.fog!==fe||pe.numClippingPlanes!==void 0&&(pe.numClippingPlanes!==we.numPlanes||pe.numIntersection!==we.numIntersection)||pe.vertexAlphas!==De||pe.vertexTangents!==Ge||pe.morphTargets!==xe||pe.morphNormals!==Je||pe.morphColors!==gt||pe.toneMapping!==ct||pe.morphTargetsCount!==It||!!pe.lightProbeGrid!=S.state.lightProbeGridArray.length>0)&&(qe=!0):(qe=!0,pe.__version=U.version);let an=pe.currentProgram;qe===!0&&(an=Dr(U,C,F),k&&U.isNodeMaterial&&k.onUpdateProgram(U,an,pe));let Rn=!1,ii=!1,Xi=!1,tt=an.getUniforms(),ft=pe.uniforms;if(M.useProgram(an.program)&&(Rn=!0,ii=!0,Xi=!0),U.id!==X&&(X=U.id,ii=!0),pe.needsLights){let ot=Tf(S.state.lightProbeGridArray,F);pe.lightProbeGrid!==ot&&(pe.lightProbeGrid=ot,ii=!0)}if(Rn||Q!==x){M.buffers.depth.getReversed()&&x.reversedDepth!==!0&&(x._reversedDepth=!0,x.updateProjectionMatrix()),tt.setValue(I,"projectionMatrix",x.projectionMatrix),tt.setValue(I,"viewMatrix",x.matrixWorldInverse);let ri=tt.map.cameraPosition;ri!==void 0&&ri.setValue(I,lt.setFromMatrixPosition(x.matrixWorld)),w.logarithmicDepthBuffer&&tt.setValue(I,"logDepthBufFC",2/(Math.log(x.far+1)/Math.LN2)),(U.isMeshPhongMaterial||U.isMeshToonMaterial||U.isMeshLambertMaterial||U.isMeshBasicMaterial||U.isMeshStandardMaterial||U.isShaderMaterial)&&tt.setValue(I,"isOrthographic",x.isOrthographicCamera===!0),Q!==x&&(Q=x,ii=!0,Xi=!0)}if(pe.needsLights&&(Ut.state.sunShadowMap.length>0&&tt.setValue(I,"sunShadowMap",Ut.state.sunShadowMap,W),Ut.state.directionalShadowMap.length>0&&tt.setValue(I,"directionalShadowMap",Ut.state.directionalShadowMap,W),Ut.state.spotShadowMap.length>0&&tt.setValue(I,"spotShadowMap",Ut.state.spotShadowMap,W),Ut.state.pointShadowMap.length>0&&tt.setValue(I,"pointShadowMap",Ut.state.pointShadowMap,W)),F.isSkinnedMesh){tt.setOptional(I,F,"bindMatrix"),tt.setOptional(I,F,"bindMatrixInverse");let ot=F.skeleton;ot&&(ot.boneTexture===null&&ot.computeBoneTexture(),tt.setValue(I,"boneTexture",ot.boneTexture,W))}F.isBatchedMesh&&(tt.setOptional(I,F,"batchingTexture"),tt.setValue(I,"batchingTexture",F._matricesTexture,W),tt.setOptional(I,F,"batchingIdTexture"),tt.setValue(I,"batchingIdTexture",F._indirectTexture,W),tt.setOptional(I,F,"batchingColorTexture"),F._colorsTexture!==null&&tt.setValue(I,"batchingColorTexture",F._colorsTexture,W));let si=G.morphAttributes;if((si.position!==void 0||si.normal!==void 0||si.color!==void 0)&&z.update(F,G,an),(ii||pe.receiveShadow!==F.receiveShadow)&&(pe.receiveShadow=F.receiveShadow,tt.setValue(I,"receiveShadow",F.receiveShadow)),(U.isMeshStandardMaterial||U.isMeshLambertMaterial||U.isMeshPhongMaterial)&&U.envMap===null&&C.environment!==null&&(ft.envMapIntensity.value=C.environmentIntensity),ft.dfgLUT!==void 0&&(ft.dfgLUT.value=vg()),ii){if(tt.setValue(I,"toneMappingExposure",P.toneMappingExposure),pe.needsLights&&Af(ft,Xi),fe&&U.fog===!0&&Se.refreshFogUniforms(ft,fe),Se.refreshMaterialUniforms(ft,U,j,q,S.state.transmissionRenderTarget[x.id]),pe.needsLights&&pe.lightProbeGrid){let ot=pe.lightProbeGrid;ft.probesSH.value=ot.texture,ft.probesMin.value.copy(ot.boundingBox.min),ft.probesMax.value.copy(ot.boundingBox.max),ft.probesResolution.value.copy(ot.resolution)}Ls.upload(I,nh(pe),ft,W)}if(U.isShaderMaterial&&U.uniformsNeedUpdate===!0&&(Ls.upload(I,nh(pe),ft,W),U.uniformsNeedUpdate=!1),U.isSpriteMaterial&&tt.setValue(I,"center",F.center),tt.setValue(I,"modelViewMatrix",F.modelViewMatrix),tt.setValue(I,"normalMatrix",F.normalMatrix),tt.setValue(I,"modelMatrix",F.matrixWorld),U.uniformsGroups!==void 0){let ot=U.uniformsGroups;for(let ri=0,qi=ot.length;ri<qi;ri++){let rh=ot[ri];ee.update(rh,an),ee.bind(rh,an)}}return an}function Af(x,C){x.ambientLightColor.needsUpdate=C,x.lightProbe.needsUpdate=C,x.sunLights.needsUpdate=C,x.sunLightShadows.needsUpdate=C,x.directionalLights.needsUpdate=C,x.directionalLightShadows.needsUpdate=C,x.pointLights.needsUpdate=C,x.pointLightShadows.needsUpdate=C,x.spotLights.needsUpdate=C,x.spotLightShadows.needsUpdate=C,x.rectAreaLights.needsUpdate=C,x.hemisphereLights.needsUpdate=C}function Rf(x){return x.isMeshLambertMaterial||x.isMeshToonMaterial||x.isMeshPhongMaterial||x.isMeshStandardMaterial||x.isShadowMaterial||x.isShaderMaterial&&x.lights===!0}this.getActiveCubeFace=function(){return K},this.getActiveMipmapLevel=function(){return Z},this.getRenderTarget=function(){return ne},this.setRenderTargetTextures=function(x,C,G){let U=B.get(x);U.__autoAllocateDepthBuffer=x.resolveDepthBuffer===!1,U.__autoAllocateDepthBuffer===!1&&(U.__useRenderToTexture=!1),B.get(x.texture).__webglTexture=C,B.get(x.depthTexture).__webglTexture=U.__autoAllocateDepthBuffer?void 0:G,U.__hasExternalTextures=!0},this.setRenderTargetFramebuffer=function(x,C){let G=B.get(x);G.__webglFramebuffer=C,G.__useDefaultFramebuffer=C===void 0},this.setRenderTarget=function(x,C=0,G=0){ne=x,K=C,Z=G;let U=null,F=!1,fe=!1;if(x){let ue=B.get(x);if(ue.__useDefaultFramebuffer!==void 0){M.bindFramebuffer(I.FRAMEBUFFER,ue.__webglFramebuffer),te.copy(x.viewport),Ae.copy(x.scissor),Te=x.scissorTest,M.viewport(te),M.scissor(Ae),M.setScissorTest(Te),X=-1;return}else if(ue.__webglFramebuffer===void 0)W.setupRenderTarget(x);else if(ue.__hasExternalTextures)W.rebindTextures(x,B.get(x.texture).__webglTexture,B.get(x.depthTexture).__webglTexture);else if(x.depthBuffer){let De=x.depthTexture;if(ue.__boundDepthTexture!==De){if(De!==null&&B.has(De)&&(x.width!==De.image.width||x.height!==De.image.height))throw new Error("THREE.WebGLRenderer: Attached DepthTexture is initialized to the incorrect size.");W.setupDepthRenderbuffer(x)}}let _e=x.texture;(_e.isData3DTexture||_e.isDataArrayTexture||_e.isCompressedArrayTexture)&&(fe=!0);let ve=B.get(x).__webglFramebuffer;x.isWebGLCubeRenderTarget?(Array.isArray(ve[C])?U=ve[C][G]:U=ve[C],F=!0):x.samples>0&&W.useMultisampledRTT(x)===!1?U=B.get(x).__webglMultisampledFramebuffer:Array.isArray(ve)?U=ve[G]:U=ve,te.copy(x.viewport),Ae.copy(x.scissor),Te=x.scissorTest}else te.copy(me).multiplyScalar(j).floor(),Ae.copy(Be).multiplyScalar(j).floor(),Te=yt;if(G!==0&&(U=H),M.bindFramebuffer(I.FRAMEBUFFER,U)&&M.drawBuffers(x,U),M.viewport(te),M.scissor(Ae),M.setScissorTest(Te),F){let ue=B.get(x.texture);I.framebufferTexture2D(I.FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_CUBE_MAP_POSITIVE_X+C,ue.__webglTexture,G)}else if(fe){let ue=C;for(let _e=0;_e<x.textures.length;_e++){let ve=B.get(x.textures[_e]);I.framebufferTextureLayer(I.FRAMEBUFFER,I.COLOR_ATTACHMENT0+_e,ve.__webglTexture,G,ue)}}else if(x!==null&&G!==0){let ue=B.get(x.texture);I.framebufferTexture2D(I.FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_2D,ue.__webglTexture,G)}X=-1};function sh(x){let C=B.get(x);return(C.__readFormat!==x.format||C.__readType!==x.type)&&(C.__readFormat=x.format,C.__readType=x.type,C.__formatReadable=w.textureFormatReadable(x.format),C.__typeReadable=w.textureTypeReadable(x.type)),C}this.readRenderTargetPixels=function(x,C,G,U,F,fe,Me,ue=0){if(!(x&&x.isWebGLRenderTarget)){ze("WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let _e=B.get(x).__webglFramebuffer;if(x.isWebGLCubeRenderTarget&&Me!==void 0&&(_e=_e[Me]),_e){M.bindFramebuffer(I.FRAMEBUFFER,_e);try{let ve=x.textures[ue],De=ve.format,Ge=ve.type;x.textures.length>1&&I.readBuffer(I.COLOR_ATTACHMENT0+ue);let xe=sh(ve);if(xe.__formatReadable===!1){ze("WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}if(xe.__typeReadable===!1){ze("WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}C>=0&&C<=x.width-U&&G>=0&&G<=x.height-F&&I.readPixels(C,G,U,F,ce.convert(De),ce.convert(Ge),fe)}finally{let ve=ne!==null?B.get(ne).__webglFramebuffer:null;M.bindFramebuffer(I.FRAMEBUFFER,ve)}}},this.readRenderTargetPixelsAsync=async function(x,C,G,U,F,fe,Me,ue=0){if(!(x&&x.isWebGLRenderTarget))throw new Error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");let _e=B.get(x).__webglFramebuffer;if(x.isWebGLCubeRenderTarget&&Me!==void 0&&(_e=_e[Me]),_e)if(C>=0&&C<=x.width-U&&G>=0&&G<=x.height-F){M.bindFramebuffer(I.FRAMEBUFFER,_e);let ve=x.textures[ue],De=ve.format,Ge=ve.type;x.textures.length>1&&I.readBuffer(I.COLOR_ATTACHMENT0+ue);let xe=sh(ve);if(xe.__formatReadable===!1)throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in RGBA or implementation defined format.");if(xe.__typeReadable===!1)throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in UnsignedByteType or implementation defined type.");let Je=I.createBuffer();I.bindBuffer(I.PIXEL_PACK_BUFFER,Je),I.bufferData(I.PIXEL_PACK_BUFFER,fe.byteLength,I.STREAM_READ),I.readPixels(C,G,U,F,ce.convert(De),ce.convert(Ge),0),I.bindBuffer(I.PIXEL_PACK_BUFFER,null);let gt=ne!==null?B.get(ne).__webglFramebuffer:null;M.bindFramebuffer(I.FRAMEBUFFER,gt);let ct=I.fenceSync(I.SYNC_GPU_COMMANDS_COMPLETE,0);return I.flush(),await Tu(I,ct,4),I.bindBuffer(I.PIXEL_PACK_BUFFER,Je),I.getBufferSubData(I.PIXEL_PACK_BUFFER,0,fe),I.bindBuffer(I.PIXEL_PACK_BUFFER,null),I.deleteBuffer(Je),I.deleteSync(ct),fe}else throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: requested read bounds are out of range.")},this.copyFramebufferToTexture=function(x,C=null,G=0){let U=Math.pow(2,-G),F=Math.floor(x.image.width*U),fe=Math.floor(x.image.height*U),Me=C!==null?C.x:0,ue=C!==null?C.y:0;W.setTexture2D(x,0),I.copyTexSubImage2D(I.TEXTURE_2D,G,0,0,Me,ue,F,fe),M.unbindTexture()},this.copyTextureToTexture=function(x,C,G=null,U=null,F=0,fe=0){let Me,ue,_e,ve,De,Ge,xe,Je,gt,ct=x.isCompressedTexture?x.mipmaps[fe]:x.image;if(G!==null)Me=G.max.x-G.min.x,ue=G.max.y-G.min.y,_e=G.isBox3?G.max.z-G.min.z:1,ve=G.min.x,De=G.min.y,Ge=G.isBox3?G.min.z:0;else{let ft=Math.pow(2,-F);Me=Math.floor(ct.width*ft),ue=Math.floor(ct.height*ft),x.isDataArrayTexture?_e=ct.depth:x.isData3DTexture?_e=Math.floor(ct.depth*ft):_e=1,ve=0,De=0,Ge=0}U!==null?(xe=U.x,Je=U.y,gt=U.z):(xe=0,Je=0,gt=0);let nt=ce.convert(C.format),It=ce.convert(C.type),pe;C.isData3DTexture?(W.setTexture3D(C,0),pe=I.TEXTURE_3D):C.isDataArrayTexture||C.isCompressedArrayTexture?(W.setTexture2DArray(C,0),pe=I.TEXTURE_2D_ARRAY):(W.setTexture2D(C,0),pe=I.TEXTURE_2D),M.activeTexture(I.TEXTURE0),M.pixelStorei(I.UNPACK_FLIP_Y_WEBGL,C.flipY),M.pixelStorei(I.UNPACK_PREMULTIPLY_ALPHA_WEBGL,C.premultiplyAlpha),M.pixelStorei(I.UNPACK_ALIGNMENT,C.unpackAlignment);let Ut=M.getParameter(I.UNPACK_ROW_LENGTH),qe=M.getParameter(I.UNPACK_IMAGE_HEIGHT),an=M.getParameter(I.UNPACK_SKIP_PIXELS),Rn=M.getParameter(I.UNPACK_SKIP_ROWS),ii=M.getParameter(I.UNPACK_SKIP_IMAGES);M.pixelStorei(I.UNPACK_ROW_LENGTH,ct.width),M.pixelStorei(I.UNPACK_IMAGE_HEIGHT,ct.height),M.pixelStorei(I.UNPACK_SKIP_PIXELS,ve),M.pixelStorei(I.UNPACK_SKIP_ROWS,De),M.pixelStorei(I.UNPACK_SKIP_IMAGES,Ge);let Xi=x.isDataArrayTexture||x.isData3DTexture,tt=C.isDataArrayTexture||C.isData3DTexture;if(x.isDepthTexture){let ft=B.get(x),si=B.get(C),ot=B.get(ft.__renderTarget),ri=B.get(si.__renderTarget);M.bindFramebuffer(I.READ_FRAMEBUFFER,ot.__webglFramebuffer),M.bindFramebuffer(I.DRAW_FRAMEBUFFER,ri.__webglFramebuffer);for(let qi=0;qi<_e;qi++)Xi&&(I.framebufferTextureLayer(I.READ_FRAMEBUFFER,I.COLOR_ATTACHMENT0,B.get(x).__webglTexture,F,Ge+qi),I.framebufferTextureLayer(I.DRAW_FRAMEBUFFER,I.COLOR_ATTACHMENT0,B.get(C).__webglTexture,fe,gt+qi)),I.blitFramebuffer(ve,De,Me,ue,xe,Je,Me,ue,I.DEPTH_BUFFER_BIT,I.NEAREST);M.bindFramebuffer(I.READ_FRAMEBUFFER,null),M.bindFramebuffer(I.DRAW_FRAMEBUFFER,null)}else if(F!==0||x.isRenderTargetTexture||B.has(x)){let ft=B.get(x),si=B.get(C);M.bindFramebuffer(I.READ_FRAMEBUFFER,L),M.bindFramebuffer(I.DRAW_FRAMEBUFFER,V);for(let ot=0;ot<_e;ot++)Xi?I.framebufferTextureLayer(I.READ_FRAMEBUFFER,I.COLOR_ATTACHMENT0,ft.__webglTexture,F,Ge+ot):I.framebufferTexture2D(I.READ_FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_2D,ft.__webglTexture,F),tt?I.framebufferTextureLayer(I.DRAW_FRAMEBUFFER,I.COLOR_ATTACHMENT0,si.__webglTexture,fe,gt+ot):I.framebufferTexture2D(I.DRAW_FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_2D,si.__webglTexture,fe),F!==0?I.blitFramebuffer(ve,De,Me,ue,xe,Je,Me,ue,I.COLOR_BUFFER_BIT,I.NEAREST):tt?I.copyTexSubImage3D(pe,fe,xe,Je,gt+ot,ve,De,Me,ue):I.copyTexSubImage2D(pe,fe,xe,Je,ve,De,Me,ue);M.bindFramebuffer(I.READ_FRAMEBUFFER,null),M.bindFramebuffer(I.DRAW_FRAMEBUFFER,null)}else tt?x.isDataTexture||x.isData3DTexture?I.texSubImage3D(pe,fe,xe,Je,gt,Me,ue,_e,nt,It,ct.data):C.isCompressedArrayTexture?I.compressedTexSubImage3D(pe,fe,xe,Je,gt,Me,ue,_e,nt,ct.data):I.texSubImage3D(pe,fe,xe,Je,gt,Me,ue,_e,nt,It,ct):x.isDataTexture?I.texSubImage2D(I.TEXTURE_2D,fe,xe,Je,Me,ue,nt,It,ct.data):x.isCompressedTexture?I.compressedTexSubImage2D(I.TEXTURE_2D,fe,xe,Je,ct.width,ct.height,nt,ct.data):I.texSubImage2D(I.TEXTURE_2D,fe,xe,Je,Me,ue,nt,It,ct);M.pixelStorei(I.UNPACK_ROW_LENGTH,Ut),M.pixelStorei(I.UNPACK_IMAGE_HEIGHT,qe),M.pixelStorei(I.UNPACK_SKIP_PIXELS,an),M.pixelStorei(I.UNPACK_SKIP_ROWS,Rn),M.pixelStorei(I.UNPACK_SKIP_IMAGES,ii),fe===0&&C.generateMipmaps&&I.generateMipmap(pe),M.unbindTexture()},this.initRenderTarget=function(x){B.get(x).__webglFramebuffer===void 0&&W.setupRenderTarget(x)},this.initTexture=function(x){x.isCubeTexture?W.setTextureCube(x,0):x.isData3DTexture?W.setTexture3D(x,0):x.isDataArrayTexture||x.isCompressedArrayTexture?W.setTexture2DArray(x,0):W.setTexture2D(x,0),M.unbindTexture()},this.resetState=function(){K=0,Z=0,ne=null,M.reset(),de.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return _n}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(e){this._outputColorSpace=e;let t=this.getContext();t.drawingBufferColorSpace=Fe._getDrawingBufferColorSpace(e),t.unpackColorSpace=Fe._getUnpackColorSpace()}};function gl(i,e){if(e===Zc)return console.warn("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Geometry already defined as triangles."),i;if(e===zs||e===Er){let t=i.getIndex();if(t===null){let r=[],a=i.getAttribute("position");if(a!==void 0){for(let o=0;o<a.count;o++)r.push(o);i.setIndex(r),t=i.getIndex()}else return console.error("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Undefined position attribute. Processing not possible."),i}let n=t.count-2,s=[];if(e===zs)for(let r=1;r<=n;r++)s.push(t.getX(0)),s.push(t.getX(r)),s.push(t.getX(r+1));else for(let r=0;r<n;r++)r%2===0?(s.push(t.getX(r)),s.push(t.getX(r+1)),s.push(t.getX(r+2))):(s.push(t.getX(r+2)),s.push(t.getX(r+1)),s.push(t.getX(r)));return s.length/3!==n&&console.error("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Unable to generate correct amount of triangles."),i.setIndex(s),i.clearGroups(),i}else return console.error("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Unknown draw mode:",e),i}function af(i){let e=new Map,t=new Map,n=i.clone();return of(i,n,function(s,r){e.set(r,s),t.set(s,r)}),n.traverse(function(s){if(!s.isSkinnedMesh)return;let r=s,a=e.get(s),o=a.skeleton.bones;r.skeleton=a.skeleton.clone(),r.bindMatrix.copy(a.bindMatrix),r.skeleton.bones=o.map(function(c){return t.get(c)}),r.bind(r.skeleton,r.bindMatrix)}),n}function of(i,e,t){t(i,e);for(let n=0;n<i.children.length;n++)of(i.children[n],e.children[n],t)}var Po=class extends Dn{constructor(e){super(e),this.dracoLoader=null,this.ktx2Loader=null,this.meshoptDecoder=null,this.pluginCallbacks=[],this.register(function(t){return new wl(t)}),this.register(function(t){return new Tl(t)}),this.register(function(t){return new Nl(t)}),this.register(function(t){return new Dl(t)}),this.register(function(t){return new Ol(t)}),this.register(function(t){return new Al(t)}),this.register(function(t){return new Rl(t)}),this.register(function(t){return new Cl(t)}),this.register(function(t){return new zl(t)}),this.register(function(t){return new Sl(t)}),this.register(function(t){return new Il(t)}),this.register(function(t){return new El(t)}),this.register(function(t){return new Ll(t)}),this.register(function(t){return new Pl(t)}),this.register(function(t){return new vl(t)}),this.register(function(t){return new Lo(t,ke.EXT_MESHOPT_COMPRESSION)}),this.register(function(t){return new Lo(t,ke.KHR_MESHOPT_COMPRESSION)}),this.register(function(t){return new Ul(t)})}load(e,t,n,s){let r=this,a;if(this.resourcePath!=="")a=this.resourcePath;else if(this.path!==""){let l=Qn.extractUrlBase(e);a=Qn.resolveURL(l,this.path)}else a=Qn.extractUrlBase(e);this.manager.itemStart(e);let o=function(l){s?s(l):console.error(l),r.manager.itemError(e),r.manager.itemEnd(e)},c=new Ss(this.manager);c.setPath(this.path),c.setResponseType("arraybuffer"),c.setRequestHeader(this.requestHeader),c.setWithCredentials(this.withCredentials),c.load(e,function(l){try{r.parse(l,a,function(h){t(h),r.manager.itemEnd(e)},o)}catch(h){o(h)}},n,o)}setDRACOLoader(e){return this.dracoLoader=e,this}setKTX2Loader(e){return this.ktx2Loader=e,this}setMeshoptDecoder(e){return this.meshoptDecoder=e,this}register(e){return this.pluginCallbacks.indexOf(e)===-1&&this.pluginCallbacks.push(e),this}unregister(e){return this.pluginCallbacks.indexOf(e)!==-1&&this.pluginCallbacks.splice(this.pluginCallbacks.indexOf(e),1),this}parse(e,t,n,s){let r,a={},o={},c=new TextDecoder;if(typeof e=="string")r=JSON.parse(e);else if(e instanceof ArrayBuffer)if(c.decode(new Uint8Array(e,0,4))===ff){try{a[ke.KHR_BINARY_GLTF]=new Fl(e)}catch(f){s&&s(f);return}r=JSON.parse(a[ke.KHR_BINARY_GLTF].content)}else r=JSON.parse(c.decode(e));else r=e;if(r.asset===void 0||r.asset.version[0]<2){s&&s(new Error("THREE.GLTFLoader: Unsupported asset. glTF versions >=2.0 are supported."));return}let l=new Xl(r,{path:t||this.resourcePath||"",crossOrigin:this.crossOrigin,requestHeader:this.requestHeader,manager:this.manager,ktx2Loader:this.ktx2Loader,meshoptDecoder:this.meshoptDecoder});l.fileLoader.setRequestHeader(this.requestHeader);for(let h=0;h<this.pluginCallbacks.length;h++){let f=this.pluginCallbacks[h](l);f.name||console.error("THREE.GLTFLoader: Invalid plugin found: missing name"),o[f.name]=f,a[f.name]=!0}if(r.extensionsUsed)for(let h=0;h<r.extensionsUsed.length;++h){let f=r.extensionsUsed[h],u=r.extensionsRequired||[];switch(f){case ke.KHR_MATERIALS_UNLIT:a[f]=new bl;break;case ke.KHR_DRACO_MESH_COMPRESSION:a[f]=new Bl(r,this.dracoLoader);break;case ke.KHR_TEXTURE_TRANSFORM:a[f]=new kl;break;case ke.KHR_MESH_QUANTIZATION:a[f]=new Vl;break;default:u.indexOf(f)>=0&&o[f]===void 0&&console.warn('THREE.GLTFLoader: Unknown extension "'+f+'".')}}l.setExtensions(a),l.setPlugins(o),l.parse(n,s)}parseAsync(e,t){let n=this;return new Promise(function(s,r){n.parse(e,t,s,r)})}};function Sg(){let i={};return{get:function(e){return i[e]},add:function(e,t){i[e]=t},remove:function(e){delete i[e]},removeAll:function(){i={}}}}function mt(i,e,t){let n=i.json.materials[e];return n.extensions&&n.extensions[t]?n.extensions[t]:null}var ke={KHR_BINARY_GLTF:"KHR_binary_glTF",KHR_DRACO_MESH_COMPRESSION:"KHR_draco_mesh_compression",KHR_LIGHTS_PUNCTUAL:"KHR_lights_punctual",KHR_MATERIALS_CLEARCOAT:"KHR_materials_clearcoat",KHR_MATERIALS_DISPERSION:"KHR_materials_dispersion",KHR_MATERIALS_IOR:"KHR_materials_ior",KHR_MATERIALS_SHEEN:"KHR_materials_sheen",KHR_MATERIALS_SPECULAR:"KHR_materials_specular",KHR_MATERIALS_TRANSMISSION:"KHR_materials_transmission",KHR_MATERIALS_IRIDESCENCE:"KHR_materials_iridescence",KHR_MATERIALS_ANISOTROPY:"KHR_materials_anisotropy",KHR_MATERIALS_UNLIT:"KHR_materials_unlit",KHR_MATERIALS_VOLUME:"KHR_materials_volume",KHR_TEXTURE_BASISU:"KHR_texture_basisu",KHR_TEXTURE_TRANSFORM:"KHR_texture_transform",KHR_MESH_QUANTIZATION:"KHR_mesh_quantization",KHR_MATERIALS_EMISSIVE_STRENGTH:"KHR_materials_emissive_strength",EXT_MATERIALS_BUMP:"EXT_materials_bump",EXT_TEXTURE_WEBP:"EXT_texture_webp",EXT_TEXTURE_AVIF:"EXT_texture_avif",EXT_MESHOPT_COMPRESSION:"EXT_meshopt_compression",KHR_MESHOPT_COMPRESSION:"KHR_meshopt_compression",EXT_MESH_GPU_INSTANCING:"EXT_mesh_gpu_instancing"},vl=class{constructor(e){this.parser=e,this.name=ke.KHR_LIGHTS_PUNCTUAL,this.cache={refs:{},uses:{}}}_markDefs(){let e=this.parser,t=this.parser.json.nodes||[];for(let n=0,s=t.length;n<s;n++){let r=t[n];r.extensions&&r.extensions[this.name]&&r.extensions[this.name].light!==void 0&&e._addNodeRef(this.cache,r.extensions[this.name].light)}}_loadLight(e){let t=this.parser,n="light:"+e,s=t.cache.get(n);if(s)return s;let r=t.json,c=((r.extensions&&r.extensions[this.name]||{}).lights||[])[e],l,h=new Ce(16777215);c.color!==void 0&&h.setRGB(c.color[0],c.color[1],c.color[2],kt);let f=c.range!==void 0?c.range:0;switch(c.type){case"directional":l=new Oi(h),l.target.position.set(0,0,-1),l.add(l.target);break;case"point":l=new mr(h),l.distance=f;break;case"spot":l=new pr(h),l.distance=f,c.spot=c.spot||{},c.spot.innerConeAngle=c.spot.innerConeAngle!==void 0?c.spot.innerConeAngle:0,c.spot.outerConeAngle=c.spot.outerConeAngle!==void 0?c.spot.outerConeAngle:Math.PI/4,l.angle=c.spot.outerConeAngle,l.penumbra=1-c.spot.innerConeAngle/c.spot.outerConeAngle,l.target.position.set(0,0,-1),l.add(l.target);break;default:throw new Error("THREE.GLTFLoader: Unexpected light type: "+c.type)}return l.position.set(0,0,0),kn(l,c),c.intensity!==void 0&&(l.intensity=c.intensity),l.name=t.createUniqueName(c.name||"light_"+e),s=Promise.resolve(l),t.cache.add(n,s),s}getDependency(e,t){if(e==="light")return this._loadLight(t)}createNodeAttachment(e){let t=this,n=this.parser,r=n.json.nodes[e],o=(r.extensions&&r.extensions[this.name]||{}).light;return o===void 0?null:this._loadLight(o).then(function(c){return n._getNodeRef(t.cache,o,c)})}},bl=class{constructor(){this.name=ke.KHR_MATERIALS_UNLIT}getMaterialType(){return yn}extendParams(e,t,n){let s=[];e.color=new Ce(1,1,1),e.opacity=1;let r=t.pbrMetallicRoughness;if(r){if(Array.isArray(r.baseColorFactor)){let a=r.baseColorFactor;e.color.setRGB(a[0],a[1],a[2],kt),e.opacity=a[3]}r.baseColorTexture!==void 0&&s.push(n.assignTexture(e,"map",r.baseColorTexture,vt))}return Promise.all(s)}},Sl=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_EMISSIVE_STRENGTH}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);return n===null||n.emissiveStrength!==void 0&&(t.emissiveIntensity=n.emissiveStrength),Promise.resolve()}},wl=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_CLEARCOAT}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];if(n.clearcoatFactor!==void 0&&(t.clearcoat=n.clearcoatFactor),n.clearcoatTexture!==void 0&&s.push(this.parser.assignTexture(t,"clearcoatMap",n.clearcoatTexture)),n.clearcoatRoughnessFactor!==void 0&&(t.clearcoatRoughness=n.clearcoatRoughnessFactor),n.clearcoatRoughnessTexture!==void 0&&s.push(this.parser.assignTexture(t,"clearcoatRoughnessMap",n.clearcoatRoughnessTexture)),n.clearcoatNormalTexture!==void 0&&(s.push(this.parser.assignTexture(t,"clearcoatNormalMap",n.clearcoatNormalTexture)),n.clearcoatNormalTexture.scale!==void 0)){let r=n.clearcoatNormalTexture.scale;t.clearcoatNormalScale=new Oe(r,r)}return Promise.all(s)}},Tl=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_DISPERSION}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);return n===null||(t.dispersion=n.dispersion!==void 0?n.dispersion:0),Promise.resolve()}},El=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_IRIDESCENCE}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];return n.iridescenceFactor!==void 0&&(t.iridescence=n.iridescenceFactor),n.iridescenceTexture!==void 0&&s.push(this.parser.assignTexture(t,"iridescenceMap",n.iridescenceTexture)),n.iridescenceIor!==void 0&&(t.iridescenceIOR=n.iridescenceIor),t.iridescenceThicknessRange===void 0&&(t.iridescenceThicknessRange=[100,400]),n.iridescenceThicknessMinimum!==void 0&&(t.iridescenceThicknessRange[0]=n.iridescenceThicknessMinimum),n.iridescenceThicknessMaximum!==void 0&&(t.iridescenceThicknessRange[1]=n.iridescenceThicknessMaximum),n.iridescenceThicknessTexture!==void 0&&s.push(this.parser.assignTexture(t,"iridescenceThicknessMap",n.iridescenceThicknessTexture)),Promise.all(s)}},Al=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_SHEEN}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];if(t.sheenColor=new Ce(0,0,0),t.sheenRoughness=0,t.sheen=1,n.sheenColorFactor!==void 0){let r=n.sheenColorFactor;t.sheenColor.setRGB(r[0],r[1],r[2],kt)}return n.sheenRoughnessFactor!==void 0&&(t.sheenRoughness=n.sheenRoughnessFactor),n.sheenColorTexture!==void 0&&s.push(this.parser.assignTexture(t,"sheenColorMap",n.sheenColorTexture,vt)),n.sheenRoughnessTexture!==void 0&&s.push(this.parser.assignTexture(t,"sheenRoughnessMap",n.sheenRoughnessTexture)),Promise.all(s)}},Rl=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_TRANSMISSION}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];return n.transmissionFactor!==void 0&&(t.transmission=n.transmissionFactor),n.transmissionTexture!==void 0&&s.push(this.parser.assignTexture(t,"transmissionMap",n.transmissionTexture)),Promise.all(s)}},Cl=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_VOLUME}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];t.thickness=n.thicknessFactor!==void 0?n.thicknessFactor:0,n.thicknessTexture!==void 0&&s.push(this.parser.assignTexture(t,"thicknessMap",n.thicknessTexture)),t.attenuationDistance=n.attenuationDistance||1/0;let r=n.attenuationColor||[1,1,1];return t.attenuationColor=new Ce().setRGB(r[0],r[1],r[2],kt),Promise.all(s)}},zl=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_IOR}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);return n===null||(t.ior=n.ior!==void 0?n.ior:1.5,t.ior===0&&(t.ior=1e3)),Promise.resolve()}},Il=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_SPECULAR}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];t.specularIntensity=n.specularFactor!==void 0?n.specularFactor:1,n.specularTexture!==void 0&&s.push(this.parser.assignTexture(t,"specularIntensityMap",n.specularTexture));let r=n.specularColorFactor||[1,1,1];return t.specularColor=new Ce().setRGB(r[0],r[1],r[2],kt),n.specularColorTexture!==void 0&&s.push(this.parser.assignTexture(t,"specularColorMap",n.specularColorTexture,vt)),Promise.all(s)}},Pl=class{constructor(e){this.parser=e,this.name=ke.EXT_MATERIALS_BUMP}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];return t.bumpScale=n.bumpFactor!==void 0?n.bumpFactor:1,n.bumpTexture!==void 0&&s.push(this.parser.assignTexture(t,"bumpMap",n.bumpTexture)),Promise.all(s)}},Ll=class{constructor(e){this.parser=e,this.name=ke.KHR_MATERIALS_ANISOTROPY}getMaterialType(e){return mt(this.parser,e,this.name)!==null?qt:null}extendMaterialParams(e,t){let n=mt(this.parser,e,this.name);if(n===null)return Promise.resolve();let s=[];return n.anisotropyStrength!==void 0&&(t.anisotropy=n.anisotropyStrength),n.anisotropyRotation!==void 0&&(t.anisotropyRotation=n.anisotropyRotation),n.anisotropyTexture!==void 0&&s.push(this.parser.assignTexture(t,"anisotropyMap",n.anisotropyTexture)),Promise.all(s)}},Nl=class{constructor(e){this.parser=e,this.name=ke.KHR_TEXTURE_BASISU}loadTexture(e){let t=this.parser,n=t.json,s=n.textures[e];if(!s.extensions||!s.extensions[this.name])return null;let r=s.extensions[this.name],a=t.options.ktx2Loader;if(!a){if(n.extensionsRequired&&n.extensionsRequired.indexOf(this.name)>=0)throw new Error("THREE.GLTFLoader: setKTX2Loader must be called before loading KTX2 textures");return null}return t.loadTextureImage(e,r.source,a)}},Dl=class{constructor(e){this.parser=e,this.name=ke.EXT_TEXTURE_WEBP}loadTexture(e){let t=this.name,n=this.parser,s=n.json,r=s.textures[e];if(!r.extensions||!r.extensions[t])return null;let a=r.extensions[t],o=s.images[a.source],c=n.textureLoader;if(o.uri){let l=n.options.manager.getHandler(o.uri);l!==null&&(c=l)}return n.loadTextureImage(e,a.source,c)}},Ol=class{constructor(e){this.parser=e,this.name=ke.EXT_TEXTURE_AVIF}loadTexture(e){let t=this.name,n=this.parser,s=n.json,r=s.textures[e];if(!r.extensions||!r.extensions[t])return null;let a=r.extensions[t],o=s.images[a.source],c=n.textureLoader;if(o.uri){let l=n.options.manager.getHandler(o.uri);l!==null&&(c=l)}return n.loadTextureImage(e,a.source,c)}},Lo=class{constructor(e,t){this.name=t,this.parser=e}loadBufferView(e){let t=this.parser.json,n=t.bufferViews[e];if(n.extensions&&n.extensions[this.name]){let s=n.extensions[this.name],r=this.parser.getDependency("buffer",s.buffer),a=this.parser.options.meshoptDecoder;if(!a||!a.supported){if(t.extensionsRequired&&t.extensionsRequired.indexOf(this.name)>=0)throw new Error("THREE.GLTFLoader: setMeshoptDecoder must be called before loading compressed files");return null}return r.then(function(o){let c=s.byteOffset||0,l=s.byteLength||0,h=s.count,f=s.byteStride,u=new Uint8Array(o,c,l);return a.decodeGltfBufferAsync?a.decodeGltfBufferAsync(h,f,u,s.mode,s.filter).then(function(d){return d.buffer}):a.ready.then(function(){let d=new ArrayBuffer(h*f);return a.decodeGltfBuffer(new Uint8Array(d),h,f,u,s.mode,s.filter),d})})}else return null}},Ul=class{constructor(e){this.name=ke.EXT_MESH_GPU_INSTANCING,this.parser=e}createNodeMesh(e){let t=this.parser.json,n=t.nodes[e];if(!n.extensions||!n.extensions[this.name]||n.mesh===void 0)return null;let s=t.meshes[n.mesh];for(let l of s.primitives)if(l.mode!==un.TRIANGLES&&l.mode!==un.TRIANGLE_STRIP&&l.mode!==un.TRIANGLE_FAN&&l.mode!==void 0)return null;let a=n.extensions[this.name].attributes,o=[],c={};for(let l in a)o.push(this.parser.getDependency("accessor",a[l]).then(h=>(c[l]=h,c[l])));return o.length<1?null:(o.push(this.parser.createNodeMesh(e)),Promise.all(o).then(l=>{let h=l.pop(),f=h.isGroup?h.children:[h],u=l[0].count,d=[];for(let g of f){let y=new Ne,m=new O,p=new Qt,T=new O(1,1,1),R=new ir(g.geometry,g.material,u);for(let b=0;b<u;b++)c.TRANSLATION&&m.fromBufferAttribute(c.TRANSLATION,b),c.ROTATION&&p.fromBufferAttribute(c.ROTATION,b),c.SCALE&&T.fromBufferAttribute(c.SCALE,b),R.setMatrixAt(b,y.compose(m,p,T));let v=null;for(let b in c)if(b==="_COLOR_0"){let S=c[b];R.instanceColor=new Zn(S.array,S.itemSize,S.normalized)}else if(b!=="TRANSLATION"&&b!=="ROTATION"&&b!=="SCALE"){if(v===null){let A=R.geometry;v=new Nt,v.name=A.name;for(let _ in A.attributes)v.setAttribute(_,A.attributes[_]);for(let _ in A.morphAttributes)v.morphAttributes[_]=A.morphAttributes[_];A.index!==null&&v.setIndex(A.index),v.morphTargetsRelative=A.morphTargetsRelative;for(let _ of A.groups)v.addGroup(_.start,_.count,_.materialIndex);A.boundingBox!==null&&(v.boundingBox=A.boundingBox.clone()),A.boundingSphere!==null&&(v.boundingSphere=A.boundingSphere.clone()),v.drawRange.start=A.drawRange.start,v.drawRange.count=A.drawRange.count,v.userData=Object.assign({},A.userData),R.geometry=v}let S=c[b];v.setAttribute(b,new Zn(S.array,S.itemSize,S.normalized))}ut.prototype.copy.call(R,g),this.parser.assignFinalMaterial(R),d.push(R)}return h.isGroup?(h.clear(),h.add(...d),h):d[0]}))}},ff="glTF",Ir=12,cf={JSON:1313821514,BIN:5130562},Fl=class{constructor(e){this.name=ke.KHR_BINARY_GLTF,this.content=null,this.body=null;let t=new DataView(e,0,Ir),n=new TextDecoder;if(this.header={magic:n.decode(new Uint8Array(e.slice(0,4))),version:t.getUint32(4,!0),length:t.getUint32(8,!0)},this.header.magic!==ff)throw new Error("THREE.GLTFLoader: Unsupported glTF-Binary header.");if(this.header.version<2)throw new Error("THREE.GLTFLoader: Legacy binary file detected.");let s=this.header.length-Ir,r=new DataView(e,Ir),a=0;for(;a<s;){let o=r.getUint32(a,!0);a+=4;let c=r.getUint32(a,!0);if(a+=4,c===cf.JSON){let l=new Uint8Array(e,Ir+a,o);this.content=n.decode(l)}else if(c===cf.BIN){let l=Ir+a;this.body=e.slice(l,l+o)}a+=o}if(this.content===null)throw new Error("THREE.GLTFLoader: JSON content not found.")}},Bl=class{constructor(e,t){if(!t)throw new Error("THREE.GLTFLoader: No DRACOLoader instance provided.");this.name=ke.KHR_DRACO_MESH_COMPRESSION,this.json=e,this.dracoLoader=t,this.dracoLoader.preload()}decodePrimitive(e,t){let n=this.json,s=this.dracoLoader,r=e.extensions[this.name].bufferView,a=e.extensions[this.name].attributes,o={},c={},l={};for(let h in a){let f=Hl[h]||h.toLowerCase();o[f]=a[h]}for(let h in e.attributes){let f=Hl[h]||h.toLowerCase();if(a[h]!==void 0){let u=n.accessors[e.attributes[h]],d=Ds[u.componentType];l[f]=d.name,c[f]=u.normalized===!0}}return t.getDependency("bufferView",r).then(function(h){return new Promise(function(f,u){s.decodeDracoFile(h,function(d){for(let g in d.attributes){let y=d.attributes[g],m=c[g];m!==void 0&&(y.normalized=m)}f(d)},o,l,kt,u)})})}},kl=class{constructor(){this.name=ke.KHR_TEXTURE_TRANSFORM}extendTexture(e,t){if((t.texCoord===void 0||t.texCoord===e.channel)&&t.offset===void 0&&t.rotation===void 0&&t.scale===void 0)return e;if(e=e.clone(),t.texCoord!==void 0&&(e.channel=t.texCoord),t.offset!==void 0&&e.offset.fromArray(t.offset),t.rotation!==void 0&&(e.rotation=t.rotation),t.scale!==void 0&&e.repeat.fromArray(t.scale),t.rotation!==void 0){let n=Math.cos(e.rotation),s=Math.sin(e.rotation);e.matrix.set(e.repeat.x*n,e.repeat.y*s,e.offset.x,-e.repeat.x*s,e.repeat.y*n,e.offset.y,0,0,1),e.matrixAutoUpdate=!1}return e.needsUpdate=!0,e}},Vl=class{constructor(){this.name=ke.KHR_MESH_QUANTIZATION}},No=class extends Nn{constructor(e,t,n,s){super(e,t,n,s)}copySampleValue_(e){let t=this.resultBuffer,n=this.sampleValues,s=this.valueSize,r=e*s*3+s;for(let a=0;a!==s;a++)t[a]=n[r+a];return t}interpolate_(e,t,n,s){let r=this.resultBuffer,a=this.sampleValues,o=this.valueSize,c=o*2,l=o*3,h=s-t,f=(n-t)/h,u=f*f,d=u*f,g=e*l,y=g-l,m=-2*d+3*u,p=d-u,T=1-m,R=p-u+f;for(let v=0;v!==o;v++){let b=a[y+v+o],S=a[y+v+c]*h,A=a[g+v+o],_=a[g+v]*h;r[v]=T*b+R*S+m*A+p*_}return r}},wg=new Qt,Gl=class extends No{interpolate_(e,t,n,s){let r=super.interpolate_(e,t,n,s);return wg.fromArray(r).normalize().toArray(r),r}},un={FLOAT:5126,FLOAT_MAT3:35675,FLOAT_MAT4:35676,FLOAT_VEC2:35664,FLOAT_VEC3:35665,FLOAT_VEC4:35666,LINEAR:9729,REPEAT:10497,SAMPLER_2D:35678,POINTS:0,LINES:1,LINE_LOOP:2,LINE_STRIP:3,TRIANGLES:4,TRIANGLE_STRIP:5,TRIANGLE_FAN:6,UNSIGNED_BYTE:5121,UNSIGNED_SHORT:5123},Ds={5120:Int8Array,5121:Uint8Array,5122:Int16Array,5123:Uint16Array,5125:Uint32Array,5126:Float32Array},lf={9728:dt,9729:pt,9984:Fa,9985:As,9986:Bi,9987:bn},hf={33071:cn,33648:ls,10497:di},_l={SCALAR:1,VEC2:2,VEC3:3,VEC4:4,MAT2:4,MAT3:9,MAT4:16},Hl={POSITION:"position",NORMAL:"normal",TANGENT:"tangent",TEXCOORD_0:"uv",TEXCOORD_1:"uv1",TEXCOORD_2:"uv2",TEXCOORD_3:"uv3",COLOR_0:"color",WEIGHTS_0:"skinWeight",JOINTS_0:"skinIndex"},vi={scale:"scale",translation:"position",rotation:"quaternion",weights:"morphTargetInfluences"},Tg={CUBICSPLINE:void 0,LINEAR:zi,STEP:Ci},xl={OPAQUE:"OPAQUE",MASK:"MASK",BLEND:"BLEND"};function Eg(i){return i.DefaultMaterial===void 0&&(i.DefaultMaterial=new Ni({color:16777215,emissive:0,metalness:1,roughness:1,transparent:!1,depthTest:!0,side:On})),i.DefaultMaterial}function Gi(i,e,t){for(let n in t.extensions)i[n]===void 0&&(e.userData.gltfExtensions=e.userData.gltfExtensions||{},e.userData.gltfExtensions[n]=t.extensions[n])}function kn(i,e){e.extras!==void 0&&(typeof e.extras=="object"?Object.assign(i.userData,e.extras):console.warn("THREE.GLTFLoader: Ignoring primitive type .extras, "+e.extras))}function Ag(i,e,t){let n=!1,s=!1,r=!1;for(let l=0,h=e.length;l<h;l++){let f=e[l];if(f.POSITION!==void 0&&(n=!0),f.NORMAL!==void 0&&(s=!0),f.COLOR_0!==void 0&&(r=!0),n&&s&&r)break}if(!n&&!s&&!r)return Promise.resolve(i);let a=[],o=[],c=[];for(let l=0,h=e.length;l<h;l++){let f=e[l];if(n){let u=f.POSITION!==void 0?t.getDependency("accessor",f.POSITION):i.attributes.position;a.push(u)}if(s){let u=f.NORMAL!==void 0?t.getDependency("accessor",f.NORMAL):i.attributes.normal;o.push(u)}if(r){let u=f.COLOR_0!==void 0?t.getDependency("accessor",f.COLOR_0):i.attributes.color;c.push(u)}}return Promise.all([Promise.all(a),Promise.all(o),Promise.all(c)]).then(function(l){let h=l[0],f=l[1],u=l[2];return n&&(i.morphAttributes.position=h),s&&(i.morphAttributes.normal=f),r&&(i.morphAttributes.color=u),i.morphTargetsRelative=!0,i})}function Rg(i,e){if(i.updateMorphTargets(),e.weights!==void 0)for(let t=0,n=e.weights.length;t<n;t++)i.morphTargetInfluences[t]=e.weights[t];if(e.extras&&Array.isArray(e.extras.targetNames)){let t=e.extras.targetNames;if(i.morphTargetInfluences.length===t.length){i.morphTargetDictionary={};for(let n=0,s=t.length;n<s;n++)i.morphTargetDictionary[t[n]]=n}else console.warn("THREE.GLTFLoader: Invalid extras.targetNames length. Ignoring names.")}}function Cg(i){let e,t=i.extensions&&i.extensions[ke.KHR_DRACO_MESH_COMPRESSION];if(t?e="draco:"+t.bufferView+":"+t.indices+":"+yl(t.attributes):e=i.indices+":"+yl(i.attributes)+":"+i.mode,i.targets!==void 0)for(let n=0,s=i.targets.length;n<s;n++)e+=":"+yl(i.targets[n]);return e}function yl(i){let e="",t=Object.keys(i).sort();for(let n=0,s=t.length;n<s;n++)e+=t[n]+":"+i[t[n]]+";";return e}function Wl(i){switch(i){case Int8Array:return 1/127;case Uint8Array:return 1/255;case Int16Array:return 1/32767;case Uint16Array:return 1/65535;default:throw new Error("THREE.GLTFLoader: Unsupported normalized accessor component type.")}}function zg(i){return i.search(/\.jpe?g($|\?)/i)>0||i.search(/^data\:image\/jpeg/)===0?"image/jpeg":i.search(/\.webp($|\?)/i)>0||i.search(/^data\:image\/webp/)===0?"image/webp":i.search(/\.ktx2($|\?)/i)>0||i.search(/^data\:image\/ktx2/)===0?"image/ktx2":"image/png"}var Ig=new Ne,Xl=class{constructor(e={},t={}){this.json=e,this.extensions={},this.plugins={},this.options=t,this.cache=new Sg,this.associations=new Map,this.primitiveCache={},this.nodeCache={},this.meshCache={refs:{},uses:{}},this.cameraCache={refs:{},uses:{}},this.lightCache={refs:{},uses:{}},this.sourceCache={},this.textureCache={},this.nodeNamesUsed={};let n=!1,s=-1,r=!1,a=-1;if(typeof navigator<"u"&&typeof navigator.userAgent<"u"){let o=navigator.userAgent;n=/^((?!chrome|android).)*safari/i.test(o)===!0;let c=o.match(/Version\/(\d+)/);s=n&&c?parseInt(c[1],10):-1,r=o.indexOf("Firefox")>-1,a=r?o.match(/Firefox\/([0-9]+)\./)[1]:-1}typeof createImageBitmap>"u"||n&&s<17||r&&a<98?this.textureLoader=new fr(this.options.manager):this.textureLoader=new gr(this.options.manager),this.textureLoader.setCrossOrigin(this.options.crossOrigin),this.textureLoader.setRequestHeader(this.options.requestHeader),this.fileLoader=new Ss(this.options.manager),this.fileLoader.setResponseType("arraybuffer"),this.options.crossOrigin==="use-credentials"&&this.fileLoader.setWithCredentials(!0)}setExtensions(e){this.extensions=e}setPlugins(e){this.plugins=e}parse(e,t){let n=this,s=this.json,r=this.extensions;this.cache.removeAll(),this.nodeCache={},this._invokeAll(function(a){return a._markDefs&&a._markDefs()}),Promise.all(this._invokeAll(function(a){return a.beforeRoot&&a.beforeRoot()})).then(function(){return Promise.all([n.getDependencies("scene"),n.getDependencies("animation"),n.getDependencies("camera")])}).then(function(a){let o={scene:a[0][s.scene||0],scenes:a[0],animations:a[1],cameras:a[2],asset:s.asset,parser:n,userData:{}};return Gi(r,o,s),kn(o,s),Promise.all(n._invokeAll(function(c){return c.afterRoot&&c.afterRoot(o)})).then(function(){for(let c of o.scenes)c.updateMatrixWorld();e(o)})}).catch(t)}_markDefs(){let e=this.json.nodes||[],t=this.json.skins||[],n=this.json.meshes||[];for(let s=0,r=t.length;s<r;s++){let a=t[s].joints;for(let o=0,c=a.length;o<c;o++)e[a[o]].isBone=!0}for(let s=0,r=e.length;s<r;s++){let a=e[s];a.mesh!==void 0&&(this._addNodeRef(this.meshCache,a.mesh),a.skin!==void 0&&(n[a.mesh].isSkinnedMesh=!0)),a.camera!==void 0&&this._addNodeRef(this.cameraCache,a.camera)}}_addNodeRef(e,t){t!==void 0&&(e.refs[t]===void 0&&(e.refs[t]=e.uses[t]=0),e.refs[t]++)}_getNodeRef(e,t,n){if(e.refs[t]<=1)return n;let s=n.clone(),r=(a,o)=>{let c=this.associations.get(a);c!=null&&this.associations.set(o,c);for(let[l,h]of a.children.entries())r(h,o.children[l])};return r(n,s),s.name+="_instance_"+e.uses[t]++,s}_invokeOne(e){let t=Object.values(this.plugins);t.push(this);for(let n=0;n<t.length;n++){let s=e(t[n]);if(s)return s}return null}_invokeAll(e){let t=Object.values(this.plugins);t.unshift(this);let n=[];for(let s=0;s<t.length;s++){let r=e(t[s]);r&&n.push(r)}return n}getDependency(e,t){let n=e+":"+t,s=this.cache.get(n);if(!s){switch(e){case"scene":s=this.loadScene(t);break;case"node":s=this._invokeOne(function(r){return r.loadNode&&r.loadNode(t)});break;case"mesh":s=this._invokeOne(function(r){return r.loadMesh&&r.loadMesh(t)});break;case"accessor":s=this.loadAccessor(t);break;case"bufferView":s=this._invokeOne(function(r){return r.loadBufferView&&r.loadBufferView(t)});break;case"buffer":s=this.loadBuffer(t);break;case"material":s=this._invokeOne(function(r){return r.loadMaterial&&r.loadMaterial(t)});break;case"texture":s=this._invokeOne(function(r){return r.loadTexture&&r.loadTexture(t)});break;case"skin":s=this.loadSkin(t);break;case"animation":s=this._invokeOne(function(r){return r.loadAnimation&&r.loadAnimation(t)});break;case"camera":s=this.loadCamera(t);break;default:if(s=this._invokeOne(function(r){return r!=this&&r.getDependency&&r.getDependency(e,t)}),!s)throw new Error("Unknown type: "+e);break}this.cache.add(n,s)}return s}getDependencies(e){let t=this.cache.get(e);if(!t){let n=this,s=this.json[e+(e==="mesh"?"es":"s")]||[];t=Promise.all(s.map(function(r,a){return n.getDependency(e,a)})),this.cache.add(e,t)}return t}loadBuffer(e){let t=this.json.buffers[e],n=this.fileLoader;if(t.type&&t.type!=="arraybuffer")throw new Error("THREE.GLTFLoader: "+t.type+" buffer type is not supported.");if(t.uri===void 0&&e===0)return Promise.resolve(this.extensions[ke.KHR_BINARY_GLTF].body);let s=this.options;return new Promise(function(r,a){n.load(Qn.resolveURL(t.uri,s.path),r,void 0,function(){a(new Error('THREE.GLTFLoader: Failed to load buffer "'+t.uri+'".'))})})}loadBufferView(e){let t=this.json.bufferViews[e];return this.getDependency("buffer",t.buffer).then(function(n){let s=t.byteLength||0,r=t.byteOffset||0;return n.slice(r,r+s)})}loadAccessor(e){let t=this,n=this.json,s=this.json.accessors[e];if(s.bufferView===void 0&&s.sparse===void 0){let a=_l[s.type],o=Ds[s.componentType],c=s.normalized===!0,l=new o(s.count*a);return Promise.resolve(new bt(l,a,c))}let r=[];return s.bufferView!==void 0?r.push(this.getDependency("bufferView",s.bufferView)):r.push(null),s.sparse!==void 0&&(r.push(this.getDependency("bufferView",s.sparse.indices.bufferView)),r.push(this.getDependency("bufferView",s.sparse.values.bufferView))),Promise.all(r).then(function(a){let o=a[0],c=_l[s.type],l=Ds[s.componentType],h=l.BYTES_PER_ELEMENT,f=h*c,u=s.byteOffset||0,d=s.bufferView!==void 0?n.bufferViews[s.bufferView].byteStride:void 0,g=s.normalized===!0,y,m;if(d&&d!==f){let p=Math.floor(u/d),T="InterleavedBuffer:"+s.bufferView+":"+s.componentType+":"+p+":"+s.count,R=t.cache.get(T);R||(y=new l(o,p*d,s.count*d/h),R=new ms(y,d/h),t.cache.add(T,R)),m=new Ms(R,c,u%d/h,g)}else o===null?y=new l(s.count*c):y=new l(o,u,s.count*c),m=new bt(y,c,g);if(s.sparse!==void 0){let p=_l.SCALAR,T=Ds[s.sparse.indices.componentType],R=s.sparse.indices.byteOffset||0,v=s.sparse.values.byteOffset||0,b=new T(a[1],R,s.sparse.count*p),S=new l(a[2],v,s.sparse.count*c);o!==null&&(m=new bt(m.array.slice(),m.itemSize,m.normalized)),m.normalized=!1;for(let A=0,_=b.length;A<_;A++){let E=b[A];if(m.setX(E,S[A*c]),c>=2&&m.setY(E,S[A*c+1]),c>=3&&m.setZ(E,S[A*c+2]),c>=4&&m.setW(E,S[A*c+3]),c>=5)throw new Error("THREE.GLTFLoader: Unsupported itemSize in sparse BufferAttribute.")}m.normalized=g}return m})}loadTexture(e){let t=this.json,n=this.options,r=t.textures[e].source,a=t.images[r],o=this.textureLoader;if(a.uri){let c=n.manager.getHandler(a.uri);c!==null&&(o=c)}return this.loadTextureImage(e,r,o)}loadTextureImage(e,t,n){let s=this,r=this.json,a=r.textures[e],o=r.images[t],c=(o.uri||o.bufferView)+":"+a.sampler;if(this.textureCache[c])return this.textureCache[c];let l=this.loadImageSource(t,n).then(function(h){h.flipY=!1,h.name=a.name||o.name||"",h.name===""&&typeof o.uri=="string"&&o.uri.startsWith("data:image/")===!1&&(h.name=o.uri);let u=(r.samplers||{})[a.sampler]||{};return h.magFilter=lf[u.magFilter]||pt,h.minFilter=lf[u.minFilter]||bn,h.wrapS=hf[u.wrapS]||di,h.wrapT=hf[u.wrapT]||di,h.generateMipmaps=!h.isCompressedTexture&&h.minFilter!==dt&&h.minFilter!==pt,s.associations.set(h,{textures:e}),h}).catch(function(){return null});return this.textureCache[c]=l,l}loadImageSource(e,t){let n=this,s=this.json,r=this.options;if(this.sourceCache[e]!==void 0)return this.sourceCache[e].then(f=>f.clone());let a=s.images[e],o=self.URL||self.webkitURL,c=a.uri||"",l=!1;if(a.bufferView!==void 0)c=n.getDependency("bufferView",a.bufferView).then(function(f){l=!0;let u=new Blob([f],{type:a.mimeType});return c=o.createObjectURL(u),c});else if(a.uri===void 0)throw new Error("THREE.GLTFLoader: Image "+e+" is missing URI and bufferView");let h=Promise.resolve(c).then(function(f){return new Promise(function(u,d){let g=u;t.isImageBitmapLoader===!0&&(g=function(y){let m=new Rt(y);m.needsUpdate=!0,u(m)}),t.load(Qn.resolveURL(f,r.path),g,void 0,d)})}).then(function(f){return l===!0&&o.revokeObjectURL(c),kn(f,a),f.userData.mimeType=a.mimeType||zg(a.uri),f}).catch(function(f){throw console.error("THREE.GLTFLoader: Couldn't load texture",c),f});return this.sourceCache[e]=h,h}assignTexture(e,t,n,s){let r=this;return this.getDependency("texture",n.index).then(function(a){if(!a)return null;if(n.texCoord!==void 0&&n.texCoord>0&&(a=a.clone(),a.channel=n.texCoord),r.extensions[ke.KHR_TEXTURE_TRANSFORM]){let o=n.extensions!==void 0?n.extensions[ke.KHR_TEXTURE_TRANSFORM]:void 0;if(o){let c=r.associations.get(a);a=r.extensions[ke.KHR_TEXTURE_TRANSFORM].extendTexture(a,o),r.associations.set(a,c)}}return s!==void 0&&(a.colorSpace=s),e[t]=a,a})}assignFinalMaterial(e){let t=e.geometry,n=e.material,s=t.attributes.tangent===void 0,r=t.attributes.color!==void 0,a=t.attributes.normal===void 0;if(e.isPoints){let o="PointsMaterial:"+n.uuid,c=this.cache.get(o);c||(c=new vs,Vt.prototype.copy.call(c,n),c.color.copy(n.color),c.map=n.map,c.sizeAttenuation=!1,this.cache.add(o,c)),n=c}else if(e.isLine){let o="LineBasicMaterial:"+n.uuid,c=this.cache.get(o);c||(c=new ys,Vt.prototype.copy.call(c,n),c.color.copy(n.color),c.map=n.map,this.cache.add(o,c)),n=c}if(s||r||a){let o="ClonedMaterial:"+n.uuid+":";s&&(o+="derivative-tangents:"),r&&(o+="vertex-colors:"),a&&(o+="flat-shading:");let c=this.cache.get(o);c||(c=n.clone(),r&&(c.vertexColors=!0),a&&(c.flatShading=!0),s&&(c.normalScale&&(c.normalScale.y*=-1),c.clearcoatNormalScale&&(c.clearcoatNormalScale.y*=-1)),this.cache.add(o,c),this.associations.set(c,this.associations.get(n))),n=c}e.material=n}getMaterialType(){return Ni}loadMaterial(e){let t=this,n=this.json,s=this.extensions,r=n.materials[e],a,o={},c=r.extensions||{},l=[];if(c[ke.KHR_MATERIALS_UNLIT]){let f=s[ke.KHR_MATERIALS_UNLIT];a=f.getMaterialType(),l.push(f.extendParams(o,r,t))}else{let f=r.pbrMetallicRoughness||{};if(o.color=new Ce(1,1,1),o.opacity=1,Array.isArray(f.baseColorFactor)){let u=f.baseColorFactor;o.color.setRGB(u[0],u[1],u[2],kt),o.opacity=u[3]}f.baseColorTexture!==void 0&&l.push(t.assignTexture(o,"map",f.baseColorTexture,vt)),o.metalness=f.metallicFactor!==void 0?f.metallicFactor:1,o.roughness=f.roughnessFactor!==void 0?f.roughnessFactor:1,f.metallicRoughnessTexture!==void 0&&(l.push(t.assignTexture(o,"metalnessMap",f.metallicRoughnessTexture)),l.push(t.assignTexture(o,"roughnessMap",f.metallicRoughnessTexture))),a=this._invokeOne(function(u){return u.getMaterialType&&u.getMaterialType(e)}),l.push(Promise.all(this._invokeAll(function(u){return u.extendMaterialParams&&u.extendMaterialParams(e,o)})))}r.doubleSided===!0&&(o.side=hn);let h=r.alphaMode||xl.OPAQUE;if(h===xl.BLEND?(o.transparent=!0,o.depthWrite=!1):(o.transparent=!1,h===xl.MASK&&(o.alphaTest=r.alphaCutoff!==void 0?r.alphaCutoff:.5)),r.normalTexture!==void 0&&a!==yn&&(l.push(t.assignTexture(o,"normalMap",r.normalTexture)),o.normalScale=new Oe(1,1),r.normalTexture.scale!==void 0)){let f=r.normalTexture.scale;o.normalScale.set(f,f)}if(r.occlusionTexture!==void 0&&a!==yn&&(l.push(t.assignTexture(o,"aoMap",r.occlusionTexture)),r.occlusionTexture.strength!==void 0&&(o.aoMapIntensity=r.occlusionTexture.strength)),r.emissiveFactor!==void 0&&a!==yn){let f=r.emissiveFactor;o.emissive=new Ce().setRGB(f[0],f[1],f[2],kt)}return r.emissiveTexture!==void 0&&a!==yn&&l.push(t.assignTexture(o,"emissiveMap",r.emissiveTexture,vt)),Promise.all(l).then(function(){let f=new a(o);return r.name&&(f.name=r.name),kn(f,r),t.associations.set(f,{materials:e}),r.extensions&&Gi(s,f,r),f})}createUniqueName(e){let t=it.sanitizeNodeName(e||"");return t in this.nodeNamesUsed?t+"_"+ ++this.nodeNamesUsed[t]:(this.nodeNamesUsed[t]=0,t)}loadGeometries(e){let t=this,n=this.extensions,s=this.primitiveCache;function r(o){return n[ke.KHR_DRACO_MESH_COMPRESSION].decodePrimitive(o,t).then(function(c){return uf(c,o,t)})}let a=[];for(let o=0,c=e.length;o<c;o++){let l=e[o],h=Cg(l),f=s[h];if(f)a.push(f.promise);else{let u;l.extensions&&l.extensions[ke.KHR_DRACO_MESH_COMPRESSION]?u=r(l):u=uf(new Nt,l,t),l.mode===un.TRIANGLE_STRIP?u=u.then(d=>gl(d,Er)):l.mode===un.TRIANGLE_FAN&&(u=u.then(d=>gl(d,zs))),s[h]={primitive:l,promise:u},a.push(u)}}return Promise.all(a)}loadMesh(e){let t=this,n=this.json,s=this.extensions,r=n.meshes[e],a=r.primitives,o=[];for(let c=0,l=a.length;c<l;c++){let h=a[c].material===void 0?Eg(this.cache):this.getDependency("material",a[c].material);o.push(h)}return o.push(t.loadGeometries(a)),Promise.all(o).then(async function(c){let l=c.slice(0,c.length-1),h=c[c.length-1],f=[];for(let d=0,g=h.length;d<g;d++){let y=h[d],m=a[d],p,T=l[d];if(m.mode===un.TRIANGLES||m.mode===un.TRIANGLE_STRIP||m.mode===un.TRIANGLE_FAN||m.mode===void 0){let R=r.isSkinnedMesh===!0,v=y.hasAttribute("skinIndex")&&y.hasAttribute("skinWeight");R&&v===!1&&console.warn("THREE.GLTFLoader: Missing skinIndex or skinWeight attributes. Skinning disabled."),p=R&&v?new tr(y,T):new Ct(y,T),p.isSkinnedMesh===!0&&p.normalizeSkinWeights()}else if(m.mode===un.LINES)p=new sr(y,T);else if(m.mode===un.LINE_STRIP)p=new Li(y,T);else if(m.mode===un.LINE_LOOP)p=new rr(y,T);else if(m.mode===un.POINTS)p=new ar(y,T);else throw new Error("THREE.GLTFLoader: Primitive mode unsupported: "+m.mode);Object.keys(p.geometry.morphAttributes).length>0&&Rg(p,r),p.name=t.createUniqueName(r.name||"mesh_"+e),kn(p,r),m.extensions&&Gi(s,p,m),t.assignFinalMaterial(p),f.push(p)}for(let d=0,g=f.length;d<g;d++)t.associations.set(f[d],{meshes:e,primitives:d});if(f.length===1)return r.extensions&&Gi(s,f[0],r),f[0];let u=new jt;r.extensions&&Gi(s,u,r),t.associations.set(u,{meshes:e});for(let d=0,g=f.length;d<g;d++)u.add(f[d]);return u})}loadCamera(e){let t,n=this.json.cameras[e],s=n[n.type];if(!s){console.warn("THREE.GLTFLoader: Missing camera parameters.");return}return n.type==="perspective"?t=new xt(yi.radToDeg(s.yfov),s.aspectRatio||1,s.znear||1,s.zfar||2e6):n.type==="orthographic"&&(t=new Mi(-s.xmag,s.xmag,s.ymag,-s.ymag,s.znear,s.zfar)),n.name&&(t.name=this.createUniqueName(n.name)),kn(t,n),Promise.resolve(t)}loadSkin(e){let t=this.json.skins[e],n=[];for(let s=0,r=t.joints.length;s<r;s++)n.push(this._loadNodeShallow(t.joints[s]));return t.inverseBindMatrices!==void 0?n.push(this.getDependency("accessor",t.inverseBindMatrices)):n.push(null),Promise.all(n).then(function(s){let r=s.pop(),a=s,o=[],c=[];for(let l=0,h=a.length;l<h;l++){let f=a[l];if(f){o.push(f);let u=new Ne;r!==null&&u.fromArray(r.array,l*16),c.push(u)}else console.warn('THREE.GLTFLoader: Joint "%s" could not be found.',t.joints[l])}return new nr(o,c)})}loadAnimation(e){let t=this.json,n=this,s=t.animations[e],r=s.name?s.name:"animation_"+e,a=[],o=[],c=[],l=[],h=[];for(let f=0,u=s.channels.length;f<u;f++){let d=s.channels[f],g=s.samplers[d.sampler],y=d.target,m=y.node,p=s.parameters!==void 0?s.parameters[g.input]:g.input,T=s.parameters!==void 0?s.parameters[g.output]:g.output;y.node!==void 0&&(a.push(this.getDependency("node",m)),o.push(this.getDependency("accessor",p)),c.push(this.getDependency("accessor",T)),l.push(g),h.push(y))}return Promise.all([Promise.all(a),Promise.all(o),Promise.all(c),Promise.all(l),Promise.all(h)]).then(function(f){let u=f[0],d=f[1],g=f[2],y=f[3],m=f[4],p=[];for(let R=0,v=u.length;R<v;R++){let b=u[R],S=d[R],A=g[R],_=y[R],E=m[R];if(b===void 0)continue;b.updateMatrix&&b.updateMatrix();let P=n._createAnimationTracks(b,S,A,_,E);if(P)for(let N=0;N<P.length;N++)p.push(P[N])}let T=new ur(r,void 0,p);return kn(T,s),T})}createNodeMesh(e){let t=this.json,n=this,s=t.nodes[e];return s.mesh===void 0?null:n.getDependency("mesh",s.mesh).then(function(r){let a=n._getNodeRef(n.meshCache,s.mesh,r);return s.weights!==void 0&&a.traverse(function(o){if(o.isMesh)for(let c=0,l=s.weights.length;c<l;c++)o.morphTargetInfluences[c]=s.weights[c]}),a})}loadNode(e){let t=this.json,n=this,s=t.nodes[e],r=n._loadNodeShallow(e),a=[],o=s.children||[];for(let l=0,h=o.length;l<h;l++)a.push(n.getDependency("node",o[l]));let c=s.skin===void 0?Promise.resolve(null):n.getDependency("skin",s.skin);return Promise.all([r,Promise.all(a),c]).then(function(l){let h=l[0],f=l[1],u=l[2];u!==null&&h.traverse(function(d){d.isSkinnedMesh&&d.bind(u,Ig)});for(let d=0,g=f.length;d<g;d++)h.add(f[d]);if(h.userData.pivot!==void 0&&f.length>0){let d=h.userData.pivot,g=f[0];h.pivot=new O().fromArray(d),h.position.x-=d[0],h.position.y-=d[1],h.position.z-=d[2],g.position.set(0,0,0),delete h.userData.pivot}return h})}_loadNodeShallow(e){let t=this.json,n=this.extensions,s=this;if(this.nodeCache[e]!==void 0)return this.nodeCache[e];let r=t.nodes[e],a=r.name?s.createUniqueName(r.name):"",o=[],c=s._invokeOne(function(l){return l.createNodeMesh&&l.createNodeMesh(e)});return c&&o.push(c),r.camera!==void 0&&o.push(s.getDependency("camera",r.camera).then(function(l){return s._getNodeRef(s.cameraCache,r.camera,l)})),s._invokeAll(function(l){return l.createNodeAttachment&&l.createNodeAttachment(e)}).forEach(function(l){o.push(l)}),this.nodeCache[e]=Promise.all(o).then(function(l){let h;if(r.isBone===!0?h=new gs:l.length>1?h=new jt:l.length===1?h=l[0]:h=new ut,h!==l[0])for(let f=0,u=l.length;f<u;f++)h.add(l[f]);if(r.name&&(h.userData.name=r.name,h.name=a),kn(h,r),r.extensions&&Gi(n,h,r),r.matrix!==void 0){let f=new Ne;f.fromArray(r.matrix),h.applyMatrix4(f)}else r.translation!==void 0&&h.position.fromArray(r.translation),r.rotation!==void 0&&h.quaternion.fromArray(r.rotation),r.scale!==void 0&&h.scale.fromArray(r.scale);if(!s.associations.has(h))s.associations.set(h,{});else if(r.mesh!==void 0&&s.meshCache.refs[r.mesh]>1){let f=s.associations.get(h);s.associations.set(h,{...f})}return s.associations.get(h).nodes=e,h}),this.nodeCache[e]}loadScene(e){let t=this.extensions,n=this.json.scenes[e],s=this,r=new jt;n.name&&(r.name=s.createUniqueName(n.name)),kn(r,n),n.extensions&&Gi(t,r,n);let a=n.nodes||[],o=[];for(let c=0,l=a.length;c<l;c++)o.push(s.getDependency("node",a[c]));return Promise.all(o).then(function(c){for(let h=0,f=c.length;h<f;h++){let u=c[h];u.parent!==null?r.add(af(u)):r.add(u)}let l=h=>{let f=new Map;for(let[u,d]of s.associations)(u instanceof Vt||u instanceof Rt)&&f.set(u,d);return h.traverse(u=>{let d=s.associations.get(u);d!=null&&f.set(u,d)}),f};return s.associations=l(r),r})}_createAnimationTracks(e,t,n,s,r){let a=[],o=e.name?e.name:e.uuid,c=[];function l(d){d.morphTargetInfluences&&c.push(d.name?d.name:d.uuid)}vi[r.path]===vi.weights?(l(e),e.isGroup&&e.children.forEach(l)):c.push(o);let h;switch(vi[r.path]){case vi.weights:h=Jn;break;case vi.rotation:h=$n;break;case vi.translation:case vi.scale:h=mi;break;default:n.itemSize===1?h=Jn:h=mi;break}let f=s.interpolation!==void 0?Tg[s.interpolation]:zi,u=this._getArrayFromAccessor(n);for(let d=0,g=c.length;d<g;d++){let y=new h(c[d]+"."+vi[r.path],t.array,u,f);s.interpolation==="CUBICSPLINE"&&this._createCubicSplineTrackInterpolant(y),a.push(y)}return a}_getArrayFromAccessor(e){let t=e.array;if(e.normalized){let n=Wl(t.constructor),s=new Float32Array(t.length);for(let r=0,a=t.length;r<a;r++)s[r]=t[r]*n;t=s}return t}_createCubicSplineTrackInterpolant(e){e.createInterpolant=function(n){let s=this instanceof $n?Gl:No;return new s(this.times,this.values,this.getValueSize()/3,n)},e.createInterpolant.isInterpolantFactoryMethodGLTFCubicSpline=!0}};function Pg(i,e,t){let n=e.attributes,s=new en;if(n.POSITION!==void 0){let o=t.json.accessors[n.POSITION],c=o.min,l=o.max;if(c!==void 0&&l!==void 0){if(s.set(new O(c[0],c[1],c[2]),new O(l[0],l[1],l[2])),o.normalized){let h=Wl(Ds[o.componentType]);s.min.multiplyScalar(h),s.max.multiplyScalar(h)}}else{console.warn("THREE.GLTFLoader: Missing min/max properties for accessor POSITION.");return}}else return;let r=e.targets;if(r!==void 0){let o=new O,c=new O;for(let l=0,h=r.length;l<h;l++){let f=r[l];if(f.POSITION!==void 0){let u=t.json.accessors[f.POSITION],d=u.min,g=u.max;if(d!==void 0&&g!==void 0){if(c.setX(Math.max(Math.abs(d[0]),Math.abs(g[0]))),c.setY(Math.max(Math.abs(d[1]),Math.abs(g[1]))),c.setZ(Math.max(Math.abs(d[2]),Math.abs(g[2]))),u.normalized){let y=Wl(Ds[u.componentType]);c.multiplyScalar(y)}o.max(c)}else console.warn("THREE.GLTFLoader: Missing min/max properties for accessor POSITION.")}}s.expandByVector(o)}i.boundingBox=s;let a=new Xt;s.getCenter(a.center),a.radius=s.min.distanceTo(s.max)/2,i.boundingSphere=a}function uf(i,e,t){let n=e.attributes,s=[];function r(a,o){return t.getDependency("accessor",a).then(function(c){i.setAttribute(o,c)})}for(let a in n){let o=Hl[a]||a.toLowerCase();o in i.attributes||s.push(r(n[a],o))}if(e.indices!==void 0&&!i.index){let a=t.getDependency("accessor",e.indices).then(function(o){i.setIndex(o)});s.push(a)}return Fe.workingColorSpace!==kt&&"COLOR_0"in n&&console.warn(`THREE.GLTFLoader: Converting vertex colors from "srgb-linear" to "${Fe.workingColorSpace}" not supported.`),kn(i,e),Pg(i,e,t),Promise.all(s).then(function(){return e.targets!==void 0?Ag(i,e.targets,t):i})}var df="Z2xURgIAAACAsQEAHI4AAEpTT057ImFzc2V0Ijp7ImdlbmVyYXRvciI6Iktocm9ub3MgZ2xURiBCbGVuZGVyIEkvTyB2NC4wLjQ0IiwidmVyc2lvbiI6IjIuMCJ9LCJzY2VuZSI6MCwic2NlbmVzIjpbeyJuYW1lIjoiU2NlbmUiLCJub2RlcyI6WzQsOCwxMywxNywyMCwyNCwyOSwzMywzOCw0Miw0NSw0OSw1Miw1NCw1Nyw2MSw2NCw2OCw3Myw3Nyw4Miw4Niw4OSw5Myw5OCwxMDIsMTA3XX1dLCJub2RlcyI6W3sibWVzaCI6MCwibmFtZSI6ImJvZHlfMDAwIn0seyJtZXNoIjoxLCJuYW1lIjoic3RpY2tlcl9CXzAwMCIsInRyYW5zbGF0aW9uIjpbMCwwLC0wLjQ4ODAwMDAzNTI4NTk0OTddfSx7Im1lc2giOjIsIm5hbWUiOiJzdGlja2VyX0RfMDAwIiwidHJhbnNsYXRpb24iOlswLC0wLjQ4ODAwMDAzNTI4NTk0OTcsMF19LHsibWVzaCI6MywibmFtZSI6InN0aWNrZXJfTF8wMDAiLCJ0cmFuc2xhdGlvbiI6Wy0wLjQ4ODAwMDAzNTI4NTk0OTcsMCwwXX0seyJjaGlsZHJlbiI6WzAsMSwyLDNdLCJuYW1lIjoiY3ViaWVfMDAwIiwidHJhbnNsYXRpb24iOlstMSwtMSwtMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMDAxIn0seyJtZXNoIjo0LCJuYW1lIjoic3RpY2tlcl9EXzAwMSIsInRyYW5zbGF0aW9uIjpbMCwtMC40ODgwMDAwMzUyODU5NDk3LDBdfSx7Im1lc2giOjUsIm5hbWUiOiJzdGlja2VyX0xfMDAxIiwidHJhbnNsYXRpb24iOlstMC40ODgwMDAwMzUyODU5NDk3LDAsMF19LHsiY2hpbGRyZW4iOls1LDYsN10sIm5hbWUiOiJjdWJpZV8wMDEiLCJ0cmFuc2xhdGlvbiI6Wy0xLC0xLDBdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzAwMiJ9LHsibWVzaCI6NiwibmFtZSI6InN0aWNrZXJfRF8wMDIiLCJ0cmFuc2xhdGlvbiI6WzAsLTAuNDg4MDAwMDM1Mjg1OTQ5NywwXX0seyJtZXNoIjo3LCJuYW1lIjoic3RpY2tlcl9GXzAwMiIsInRyYW5zbGF0aW9uIjpbMCwwLDAuNDg4MDAwMDM1Mjg1OTQ5N119LHsibWVzaCI6OCwibmFtZSI6InN0aWNrZXJfTF8wMDIiLCJ0cmFuc2xhdGlvbiI6Wy0wLjQ4ODAwMDAzNTI4NTk0OTcsMCwwXX0seyJjaGlsZHJlbiI6WzksMTAsMTEsMTJdLCJuYW1lIjoiY3ViaWVfMDAyIiwidHJhbnNsYXRpb24iOlstMSwtMSwxXX0seyJtZXNoIjowLCJuYW1lIjoiYm9keV8wMTAifSx7Im1lc2giOjksIm5hbWUiOiJzdGlja2VyX0JfMDEwIiwidHJhbnNsYXRpb24iOlswLDAsLTAuNDg4MDAwMDM1Mjg1OTQ5N119LHsibWVzaCI6MTAsIm5hbWUiOiJzdGlja2VyX0xfMDEwIiwidHJhbnNsYXRpb24iOlstMC40ODgwMDAwMzUyODU5NDk3LDAsMF19LHsiY2hpbGRyZW4iOlsxNCwxNSwxNl0sIm5hbWUiOiJjdWJpZV8wMTAiLCJ0cmFuc2xhdGlvbiI6Wy0xLDAsLTFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzAxMSJ9LHsibWVzaCI6MTEsIm5hbWUiOiJzdGlja2VyX0xfMDExIiwidHJhbnNsYXRpb24iOlstMC40ODgwMDAwMzUyODU5NDk3LDAsMF19LHsiY2hpbGRyZW4iOlsxOCwxOV0sIm5hbWUiOiJjdWJpZV8wMTEiLCJ0cmFuc2xhdGlvbiI6Wy0xLDAsMF19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMDEyIn0seyJtZXNoIjoxMiwibmFtZSI6InN0aWNrZXJfRl8wMTIiLCJ0cmFuc2xhdGlvbiI6WzAsMCwwLjQ4ODAwMDAzNTI4NTk0OTddfSx7Im1lc2giOjEzLCJuYW1lIjoic3RpY2tlcl9MXzAxMiIsInRyYW5zbGF0aW9uIjpbLTAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7ImNoaWxkcmVuIjpbMjEsMjIsMjNdLCJuYW1lIjoiY3ViaWVfMDEyIiwidHJhbnNsYXRpb24iOlstMSwwLDFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzAyMCJ9LHsibWVzaCI6MTQsIm5hbWUiOiJzdGlja2VyX0JfMDIwIiwidHJhbnNsYXRpb24iOlswLDAsLTAuNDg4MDAwMDM1Mjg1OTQ5N119LHsibWVzaCI6MTUsIm5hbWUiOiJzdGlja2VyX0xfMDIwIiwidHJhbnNsYXRpb24iOlstMC40ODgwMDAwMzUyODU5NDk3LDAsMF19LHsibWVzaCI6MTYsIm5hbWUiOiJzdGlja2VyX1VfMDIwIiwidHJhbnNsYXRpb24iOlswLDAuNDg4MDAwMDM1Mjg1OTQ5NywwXX0seyJjaGlsZHJlbiI6WzI1LDI2LDI3LDI4XSwibmFtZSI6ImN1YmllXzAyMCIsInRyYW5zbGF0aW9uIjpbLTEsMSwtMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMDIxIn0seyJtZXNoIjoxNywibmFtZSI6InN0aWNrZXJfTF8wMjEiLCJ0cmFuc2xhdGlvbiI6Wy0wLjQ4ODAwMDAzNTI4NTk0OTcsMCwwXX0seyJtZXNoIjoxOCwibmFtZSI6InN0aWNrZXJfVV8wMjEiLCJ0cmFuc2xhdGlvbiI6WzAsMC40ODgwMDAwMzUyODU5NDk3LDBdfSx7ImNoaWxkcmVuIjpbMzAsMzEsMzJdLCJuYW1lIjoiY3ViaWVfMDIxIiwidHJhbnNsYXRpb24iOlstMSwxLDBdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzAyMiJ9LHsibWVzaCI6MTksIm5hbWUiOiJzdGlja2VyX0ZfMDIyIiwidHJhbnNsYXRpb24iOlswLDAsMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjoyMCwibmFtZSI6InN0aWNrZXJfTF8wMjIiLCJ0cmFuc2xhdGlvbiI6Wy0wLjQ4ODAwMDAzNTI4NTk0OTcsMCwwXX0seyJtZXNoIjoyMSwibmFtZSI6InN0aWNrZXJfVV8wMjIiLCJ0cmFuc2xhdGlvbiI6WzAsMC40ODgwMDAwMzUyODU5NDk3LDBdfSx7ImNoaWxkcmVuIjpbMzQsMzUsMzYsMzddLCJuYW1lIjoiY3ViaWVfMDIyIiwidHJhbnNsYXRpb24iOlstMSwxLDFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzEwMCJ9LHsibWVzaCI6MjIsIm5hbWUiOiJzdGlja2VyX0JfMTAwIiwidHJhbnNsYXRpb24iOlswLDAsLTAuNDg4MDAwMDM1Mjg1OTQ5N119LHsibWVzaCI6MjMsIm5hbWUiOiJzdGlja2VyX0RfMTAwIiwidHJhbnNsYXRpb24iOlswLC0wLjQ4ODAwMDAzNTI4NTk0OTcsMF19LHsiY2hpbGRyZW4iOlszOSw0MCw0MV0sIm5hbWUiOiJjdWJpZV8xMDAiLCJ0cmFuc2xhdGlvbiI6WzAsLTEsLTFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzEwMSJ9LHsibWVzaCI6MjQsIm5hbWUiOiJzdGlja2VyX0RfMTAxIiwidHJhbnNsYXRpb24iOlswLC0wLjQ4ODAwMDAzNTI4NTk0OTcsMF19LHsiY2hpbGRyZW4iOls0Myw0NF0sIm5hbWUiOiJjdWJpZV8xMDEiLCJ0cmFuc2xhdGlvbiI6WzAsLTEsMF19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMTAyIn0seyJtZXNoIjoyNSwibmFtZSI6InN0aWNrZXJfRF8xMDIiLCJ0cmFuc2xhdGlvbiI6WzAsLTAuNDg4MDAwMDM1Mjg1OTQ5NywwXX0seyJtZXNoIjoyNiwibmFtZSI6InN0aWNrZXJfRl8xMDIiLCJ0cmFuc2xhdGlvbiI6WzAsMCwwLjQ4ODAwMDAzNTI4NTk0OTddfSx7ImNoaWxkcmVuIjpbNDYsNDcsNDhdLCJuYW1lIjoiY3ViaWVfMTAyIiwidHJhbnNsYXRpb24iOlswLC0xLDFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzExMCJ9LHsibWVzaCI6MjcsIm5hbWUiOiJzdGlja2VyX0JfMTEwIiwidHJhbnNsYXRpb24iOlswLDAsLTAuNDg4MDAwMDM1Mjg1OTQ5N119LHsiY2hpbGRyZW4iOls1MCw1MV0sIm5hbWUiOiJjdWJpZV8xMTAiLCJ0cmFuc2xhdGlvbiI6WzAsMCwtMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMTExIn0seyJjaGlsZHJlbiI6WzUzXSwibmFtZSI6ImN1YmllXzExMSJ9LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMTEyIn0seyJtZXNoIjoyOCwibmFtZSI6InN0aWNrZXJfRl8xMTIiLCJ0cmFuc2xhdGlvbiI6WzAsMCwwLjQ4ODAwMDAzNTI4NTk0OTddfSx7ImNoaWxkcmVuIjpbNTUsNTZdLCJuYW1lIjoiY3ViaWVfMTEyIiwidHJhbnNsYXRpb24iOlswLDAsMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMTIwIn0seyJtZXNoIjoyOSwibmFtZSI6InN0aWNrZXJfQl8xMjAiLCJ0cmFuc2xhdGlvbiI6WzAsMCwtMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjozMCwibmFtZSI6InN0aWNrZXJfVV8xMjAiLCJ0cmFuc2xhdGlvbiI6WzAsMC40ODgwMDAwMzUyODU5NDk3LDBdfSx7ImNoaWxkcmVuIjpbNTgsNTksNjBdLCJuYW1lIjoiY3ViaWVfMTIwIiwidHJhbnNsYXRpb24iOlswLDEsLTFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzEyMSJ9LHsibWVzaCI6MzEsIm5hbWUiOiJzdGlja2VyX1VfMTIxIiwidHJhbnNsYXRpb24iOlswLDAuNDg4MDAwMDM1Mjg1OTQ5NywwXX0seyJjaGlsZHJlbiI6WzYyLDYzXSwibmFtZSI6ImN1YmllXzEyMSIsInRyYW5zbGF0aW9uIjpbMCwxLDBdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzEyMiJ9LHsibWVzaCI6MzIsIm5hbWUiOiJzdGlja2VyX0ZfMTIyIiwidHJhbnNsYXRpb24iOlswLDAsMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjozMywibmFtZSI6InN0aWNrZXJfVV8xMjIiLCJ0cmFuc2xhdGlvbiI6WzAsMC40ODgwMDAwMzUyODU5NDk3LDBdfSx7ImNoaWxkcmVuIjpbNjUsNjYsNjddLCJuYW1lIjoiY3ViaWVfMTIyIiwidHJhbnNsYXRpb24iOlswLDEsMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMjAwIn0seyJtZXNoIjozNCwibmFtZSI6InN0aWNrZXJfQl8yMDAiLCJ0cmFuc2xhdGlvbiI6WzAsMCwtMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjozNSwibmFtZSI6InN0aWNrZXJfRF8yMDAiLCJ0cmFuc2xhdGlvbiI6WzAsLTAuNDg4MDAwMDM1Mjg1OTQ5NywwXX0seyJtZXNoIjozNiwibmFtZSI6InN0aWNrZXJfUl8yMDAiLCJ0cmFuc2xhdGlvbiI6WzAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7ImNoaWxkcmVuIjpbNjksNzAsNzEsNzJdLCJuYW1lIjoiY3ViaWVfMjAwIiwidHJhbnNsYXRpb24iOlsxLC0xLC0xXX0seyJtZXNoIjowLCJuYW1lIjoiYm9keV8yMDEifSx7Im1lc2giOjM3LCJuYW1lIjoic3RpY2tlcl9EXzIwMSIsInRyYW5zbGF0aW9uIjpbMCwtMC40ODgwMDAwMzUyODU5NDk3LDBdfSx7Im1lc2giOjM4LCJuYW1lIjoic3RpY2tlcl9SXzIwMSIsInRyYW5zbGF0aW9uIjpbMC40ODgwMDAwMzUyODU5NDk3LDAsMF19LHsiY2hpbGRyZW4iOls3NCw3NSw3Nl0sIm5hbWUiOiJjdWJpZV8yMDEiLCJ0cmFuc2xhdGlvbiI6WzEsLTEsMF19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMjAyIn0seyJtZXNoIjozOSwibmFtZSI6InN0aWNrZXJfRF8yMDIiLCJ0cmFuc2xhdGlvbiI6WzAsLTAuNDg4MDAwMDM1Mjg1OTQ5NywwXX0seyJtZXNoIjo0MCwibmFtZSI6InN0aWNrZXJfRl8yMDIiLCJ0cmFuc2xhdGlvbiI6WzAsMCwwLjQ4ODAwMDAzNTI4NTk0OTddfSx7Im1lc2giOjQxLCJuYW1lIjoic3RpY2tlcl9SXzIwMiIsInRyYW5zbGF0aW9uIjpbMC40ODgwMDAwMzUyODU5NDk3LDAsMF19LHsiY2hpbGRyZW4iOls3OCw3OSw4MCw4MV0sIm5hbWUiOiJjdWJpZV8yMDIiLCJ0cmFuc2xhdGlvbiI6WzEsLTEsMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMjEwIn0seyJtZXNoIjo0MiwibmFtZSI6InN0aWNrZXJfQl8yMTAiLCJ0cmFuc2xhdGlvbiI6WzAsMCwtMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjo0MywibmFtZSI6InN0aWNrZXJfUl8yMTAiLCJ0cmFuc2xhdGlvbiI6WzAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7ImNoaWxkcmVuIjpbODMsODQsODVdLCJuYW1lIjoiY3ViaWVfMjEwIiwidHJhbnNsYXRpb24iOlsxLDAsLTFdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzIxMSJ9LHsibWVzaCI6NDQsIm5hbWUiOiJzdGlja2VyX1JfMjExIiwidHJhbnNsYXRpb24iOlswLjQ4ODAwMDAzNTI4NTk0OTcsMCwwXX0seyJjaGlsZHJlbiI6Wzg3LDg4XSwibmFtZSI6ImN1YmllXzIxMSIsInRyYW5zbGF0aW9uIjpbMSwwLDBdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzIxMiJ9LHsibWVzaCI6NDUsIm5hbWUiOiJzdGlja2VyX0ZfMjEyIiwidHJhbnNsYXRpb24iOlswLDAsMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjo0NiwibmFtZSI6InN0aWNrZXJfUl8yMTIiLCJ0cmFuc2xhdGlvbiI6WzAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7ImNoaWxkcmVuIjpbOTAsOTEsOTJdLCJuYW1lIjoiY3ViaWVfMjEyIiwidHJhbnNsYXRpb24iOlsxLDAsMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMjIwIn0seyJtZXNoIjo0NywibmFtZSI6InN0aWNrZXJfQl8yMjAiLCJ0cmFuc2xhdGlvbiI6WzAsMCwtMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjo0OCwibmFtZSI6InN0aWNrZXJfUl8yMjAiLCJ0cmFuc2xhdGlvbiI6WzAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7Im1lc2giOjQ5LCJuYW1lIjoic3RpY2tlcl9VXzIyMCIsInRyYW5zbGF0aW9uIjpbMCwwLjQ4ODAwMDAzNTI4NTk0OTcsMF19LHsiY2hpbGRyZW4iOls5NCw5NSw5Niw5N10sIm5hbWUiOiJjdWJpZV8yMjAiLCJ0cmFuc2xhdGlvbiI6WzEsMSwtMV19LHsibWVzaCI6MCwibmFtZSI6ImJvZHlfMjIxIn0seyJtZXNoIjo1MCwibmFtZSI6InN0aWNrZXJfUl8yMjEiLCJ0cmFuc2xhdGlvbiI6WzAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7Im1lc2giOjUxLCJuYW1lIjoic3RpY2tlcl9VXzIyMSIsInRyYW5zbGF0aW9uIjpbMCwwLjQ4ODAwMDAzNTI4NTk0OTcsMF19LHsiY2hpbGRyZW4iOls5OSwxMDAsMTAxXSwibmFtZSI6ImN1YmllXzIyMSIsInRyYW5zbGF0aW9uIjpbMSwxLDBdfSx7Im1lc2giOjAsIm5hbWUiOiJib2R5XzIyMiJ9LHsibWVzaCI6NTIsIm5hbWUiOiJzdGlja2VyX0ZfMjIyIiwidHJhbnNsYXRpb24iOlswLDAsMC40ODgwMDAwMzUyODU5NDk3XX0seyJtZXNoIjo1MywibmFtZSI6InN0aWNrZXJfUl8yMjIiLCJ0cmFuc2xhdGlvbiI6WzAuNDg4MDAwMDM1Mjg1OTQ5NywwLDBdfSx7Im1lc2giOjU0LCJuYW1lIjoic3RpY2tlcl9VXzIyMiIsInRyYW5zbGF0aW9uIjpbMCwwLjQ4ODAwMDAzNTI4NTk0OTcsMF19LHsiY2hpbGRyZW4iOlsxMDMsMTA0LDEwNSwxMDZdLCJuYW1lIjoiY3ViaWVfMjIyIiwidHJhbnNsYXRpb24iOlsxLDEsMV19XSwibWF0ZXJpYWxzIjpbeyJkb3VibGVTaWRlZCI6dHJ1ZSwibmFtZSI6InBsYXN0aWNfYmxhY2siLCJwYnJNZXRhbGxpY1JvdWdobmVzcyI6eyJiYXNlQ29sb3JGYWN0b3IiOlswLjAzOTk5OTk5OTEwNTkzMDMzLDAuMDM5OTk5OTk5MTA1OTMwMzMsMC4wMzk5OTk5OTkxMDU5MzAzMywxXSwibWV0YWxsaWNGYWN0b3IiOjAsInJvdWdobmVzc0ZhY3RvciI6MC40NDk5OTk5ODgwNzkwNzEwNH19LHsiZG91YmxlU2lkZWQiOnRydWUsIm5hbWUiOiJzdGlja2VyX0IiLCJwYnJNZXRhbGxpY1JvdWdobmVzcyI6eyJiYXNlQ29sb3JGYWN0b3IiOlswLjA4MjAwMDAwMjI2NDk3NjUsMC4zOTU5OTk5OTc4NTQyMzI4LDAuNzUzMDAwMDIwOTgwODM1LDFdLCJtZXRhbGxpY0ZhY3RvciI6MCwicm91Z2huZXNzRmFjdG9yIjowLjM0OTk5OTk5NDAzOTUzNTV9fSx7ImRvdWJsZVNpZGVkIjp0cnVlLCJuYW1lIjoic3RpY2tlcl9EIiwicGJyTWV0YWxsaWNSb3VnaG5lc3MiOnsiYmFzZUNvbG9yRmFjdG9yIjpbMSwwLjkwMjAwMDAxMDAxMzU4MDMsMCwxXSwibWV0YWxsaWNGYWN0b3IiOjAsInJvdWdobmVzc0ZhY3RvciI6MC4zNDk5OTk5OTQwMzk1MzU1fX0seyJkb3VibGVTaWRlZCI6dHJ1ZSwibmFtZSI6InN0aWNrZXJfTCIsInBick1ldGFsbGljUm91Z2huZXNzIjp7ImJhc2VDb2xvckZhY3RvciI6WzEsMC41NDkwMDAwMjQ3OTU1MzIyLDAsMV0sIm1ldGFsbGljRmFjdG9yIjowLCJyb3VnaG5lc3NGYWN0b3IiOjAuMzQ5OTk5OTk0MDM5NTM1NX19LHsiZG91YmxlU2lkZWQiOnRydWUsIm5hbWUiOiJzdGlja2VyX0YiLCJwYnJNZXRhbGxpY1JvdWdobmVzcyI6eyJiYXNlQ29sb3JGYWN0b3IiOlswLjE4MDAwMDAwNzE1MjU1NzM3LDAuNjY2OTk5OTk1NzA4NDY1NiwwLjMxMDAwMDAwMjM4NDE4NTgsMV0sIm1ldGFsbGljRmFjdG9yIjowLCJyb3VnaG5lc3NGYWN0b3IiOjAuMzQ5OTk5OTk0MDM5NTM1NX19LHsiZG91YmxlU2lkZWQiOnRydWUsIm5hbWUiOiJzdGlja2VyX1UiLCJwYnJNZXRhbGxpY1JvdWdobmVzcyI6eyJtZXRhbGxpY0ZhY3RvciI6MCwicm91Z2huZXNzRmFjdG9yIjowLjM0OTk5OTk5NDAzOTUzNTV9fSx7ImRvdWJsZVNpZGVkIjp0cnVlLCJuYW1lIjoic3RpY2tlcl9SIiwicGJyTWV0YWxsaWNSb3VnaG5lc3MiOnsiYmFzZUNvbG9yRmFjdG9yIjpbMC44OTgwMDAwMDE5MDczNDg2LDAuMjI0MDAwMDA2OTE0MTM4OCwwLjIwODAwMDAwNDI5MTUzNDQyLDFdLCJtZXRhbGxpY0ZhY3RvciI6MCwicm91Z2huZXNzRmFjdG9yIjowLjM0OTk5OTk5NDAzOTUzNTV9fV0sIm1lc2hlcyI6W3sibmFtZSI6ImJvZHlfbWVzaCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjAsIk5PUk1BTCI6MX0sImluZGljZXMiOjIsIm1hdGVyaWFsIjowfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMDBfQiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjMsIk5PUk1BTCI6NH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoxfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMDBfRCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjUsIk5PUk1BTCI6Nn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoyfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMDBfTCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjcsIk5PUk1BTCI6OH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjozfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMDFfRCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjksIk5PUk1BTCI6MTB9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6Mn1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMDAxX0wiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjoxMSwiTk9STUFMIjoxMn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjozfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMDJfRCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjEzLCJOT1JNQUwiOjE0fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjJ9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzAwMl9GIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MTUsIk5PUk1BTCI6MTZ9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NH1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMDAyX0wiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjoxNywiTk9STUFMIjoxOH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjozfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMTBfQiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjE5LCJOT1JNQUwiOjIwfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjF9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzAxMF9MIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MjEsIk5PUk1BTCI6MjJ9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6M31dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMDExX0wiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjoyMywiTk9STUFMIjoyNH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjozfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMTJfRiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjI1LCJOT1JNQUwiOjI2fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjR9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzAxMl9MIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MjcsIk5PUk1BTCI6Mjh9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6M31dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMDIwX0IiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjoyOSwiTk9STUFMIjozMH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoxfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMjBfTCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjMxLCJOT1JNQUwiOjMyfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjN9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzAyMF9VIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MzMsIk5PUk1BTCI6MzR9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NX1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMDIxX0wiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjozNSwiTk9STUFMIjozNn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjozfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMjFfVSIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjM3LCJOT1JNQUwiOjM4fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjV9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzAyMl9GIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MzksIk5PUk1BTCI6NDB9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NH1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMDIyX0wiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo0MSwiTk9STUFMIjo0Mn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjozfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8wMjJfVSIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjQzLCJOT1JNQUwiOjQ0fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjV9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzEwMF9CIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6NDUsIk5PUk1BTCI6NDZ9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6MX1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMTAwX0QiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo0NywiTk9STUFMIjo0OH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoyfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8xMDFfRCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjQ5LCJOT1JNQUwiOjUwfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjJ9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzEwMl9EIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6NTEsIk5PUk1BTCI6NTJ9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6Mn1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMTAyX0YiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo1MywiTk9STUFMIjo1NH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo0fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8xMTBfQiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjU1LCJOT1JNQUwiOjU2fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjF9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzExMl9GIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6NTcsIk5PUk1BTCI6NTh9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NH1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMTIwX0IiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo1OSwiTk9STUFMIjo2MH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoxfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8xMjBfVSIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjYxLCJOT1JNQUwiOjYyfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjV9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzEyMV9VIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6NjMsIk5PUk1BTCI6NjR9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NX1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMTIyX0YiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo2NSwiTk9STUFMIjo2Nn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo0fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8xMjJfVSIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjY3LCJOT1JNQUwiOjY4fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjV9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIwMF9CIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6NjksIk5PUk1BTCI6NzB9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6MX1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMjAwX0QiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo3MSwiTk9STUFMIjo3Mn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoyfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMDBfUiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjczLCJOT1JNQUwiOjc0fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjZ9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIwMV9EIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6NzUsIk5PUk1BTCI6NzZ9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6Mn1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMjAxX1IiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo3NywiTk9STUFMIjo3OH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo2fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMDJfRCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjc5LCJOT1JNQUwiOjgwfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjJ9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIwMl9GIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6ODEsIk5PUk1BTCI6ODJ9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NH1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMjAyX1IiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo4MywiTk9STUFMIjo4NH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo2fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMTBfQiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjg1LCJOT1JNQUwiOjg2fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjF9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIxMF9SIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6ODcsIk5PUk1BTCI6ODh9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6Nn1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMjExX1IiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo4OSwiTk9STUFMIjo5MH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo2fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMTJfRiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjkxLCJOT1JNQUwiOjkyfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjR9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIxMl9SIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6OTMsIk5PUk1BTCI6OTR9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6Nn1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMjIwX0IiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjo5NSwiTk9STUFMIjo5Nn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjoxfV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMjBfUiIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjk3LCJOT1JNQUwiOjk4fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjZ9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIyMF9VIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6OTksIk5PUk1BTCI6MTAwfSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjV9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIyMV9SIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MTAxLCJOT1JNQUwiOjEwMn0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo2fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMjFfVSIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjEwMywiTk9STUFMIjoxMDR9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NX1dfSx7Im5hbWUiOiJzdGlja2VyX21lc2hfY3ViaWVfMjIyX0YiLCJwcmltaXRpdmVzIjpbeyJhdHRyaWJ1dGVzIjp7IlBPU0lUSU9OIjoxMDUsIk5PUk1BTCI6MTA2fSwiaW5kaWNlcyI6MiwibWF0ZXJpYWwiOjR9XX0seyJuYW1lIjoic3RpY2tlcl9tZXNoX2N1YmllXzIyMl9SIiwicHJpbWl0aXZlcyI6W3siYXR0cmlidXRlcyI6eyJQT1NJVElPTiI6MTA3LCJOT1JNQUwiOjEwOH0sImluZGljZXMiOjIsIm1hdGVyaWFsIjo2fV19LHsibmFtZSI6InN0aWNrZXJfbWVzaF9jdWJpZV8yMjJfVSIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjEwOSwiTk9STUFMIjoxMTB9LCJpbmRpY2VzIjoyLCJtYXRlcmlhbCI6NX1dfV0sImFjY2Vzc29ycyI6W3siYnVmZmVyVmlldyI6MCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQ3OTk5OTk4OTI3MTE2Mzk0LDAuNDc5OTk5OTg5MjcxMTYzOTQsMC40Nzk5OTk5ODkyNzExNjM5NF0sIm1pbiI6Wy0wLjQ3OTk5OTk4OTI3MTE2Mzk0LC0wLjQ3OTk5OTk4OTI3MTE2Mzk0LC0wLjQ3OTk5OTk4OTI3MTE2Mzk0XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjEsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjIsImNvbXBvbmVudFR5cGUiOjUxMjMsImNvdW50IjozMjQsInR5cGUiOiJTQ0FMQVIifSx7ImJ1ZmZlclZpZXciOjMsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo2LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo3LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjgsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjksImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTAsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjExLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjEyLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxMywiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxNCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTUsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTYsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjE3LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjE4LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxOSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoyMCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MjEsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MjIsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjIzLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjI0LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoyNSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoyNiwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MjcsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MjgsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjI5LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjMwLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjozMSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjAzMDAwMDAwMTE5MjA5Mjg5NiwwLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjozMiwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MzMsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MzQsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjM1LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjM2LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjozNywiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjozOCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MzksImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NDAsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjQxLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjQyLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo0MywiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo0NCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NDUsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NDYsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjQ3LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5NiwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjQ4LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo0OSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo1MCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NTEsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NTIsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjUzLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjU0LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo1NSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo1NiwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NTcsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NTgsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjU5LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjYwLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo2MSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo2MiwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NjMsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NjQsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjY1LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjY2LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo2NywiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo2OCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NjksImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NzAsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjcxLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5NiwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjcyLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo3MywiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjAzMDAwMDAwMTE5MjA5Mjg5NiwwLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo3NCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NzUsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6NzYsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjc3LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjc4LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo3OSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo4MCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6ODEsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6ODIsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjgzLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjg0LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo4NSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo4NiwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6ODcsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6ODgsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjg5LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDVdLCJtaW4iOlstMC4wMzAwMDAwMDExOTIwOTI4OTYsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjkwLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo5MSwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2XSwibWluIjpbLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo5MiwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6OTMsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6OTQsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjk1LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsIm1heCI6WzAuNDAwMDAwMDA1OTYwNDY0NSwwLjQwMDAwMDAwNTk2MDQ2NDUsMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJtaW4iOlstMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2XSwidHlwZSI6IlZFQzMifSx7ImJ1ZmZlclZpZXciOjk2LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo5NywiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJtYXgiOlswLjAzMDAwMDAwMTE5MjA5Mjg5NiwwLjQwMDAwMDAwNTk2MDQ2NDUsMC40MDAwMDAwMDU5NjA0NjQ1XSwibWluIjpbLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NV0sInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3Ijo5OCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjU2LCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6OTksImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTAwLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxMDEsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTAyLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxMDMsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTA0LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxMDUsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NSwwLjAzMDAwMDAwMTE5MjA5Mjg5Nl0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuNDAwMDAwMDA1OTYwNDY0NSwtMC4wMzAwMDAwMDExOTIwOTI4OTZdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTA2LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxMDcsImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC4wMzAwMDAwMDExOTIwOTI4OTYsMC40MDAwMDAwMDU5NjA0NjQ1LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjAzMDAwMDAwMTE5MjA5Mjg5NiwtMC40MDAwMDAwMDU5NjA0NjQ1LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTA4LCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn0seyJidWZmZXJWaWV3IjoxMDksImNvbXBvbmVudFR5cGUiOjUxMjYsImNvdW50Ijo1NiwibWF4IjpbMC40MDAwMDAwMDU5NjA0NjQ1LDAuMDMwMDAwMDAxMTkyMDkyODk2LDAuNDAwMDAwMDA1OTYwNDY0NV0sIm1pbiI6Wy0wLjQwMDAwMDAwNTk2MDQ2NDUsLTAuMDMwMDAwMDAxMTkyMDkyODk2LC0wLjQwMDAwMDAwNTk2MDQ2NDVdLCJ0eXBlIjoiVkVDMyJ9LHsiYnVmZmVyVmlldyI6MTEwLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6NTYsInR5cGUiOiJWRUMzIn1dLCJidWZmZXJWaWV3cyI6W3siYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjY3MiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY0OCwiYnl0ZU9mZnNldCI6MTM0NCwidGFyZ2V0IjozNDk2M30seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MTk5MiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MjY2NCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MzMzNiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDAwOCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDY4MCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NTM1MiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NjAyNCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NjY5NiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NzM2OCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6ODA0MCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6ODcxMiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6OTM4NCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MTAwNTYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjEwNzI4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoxMTQwMCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MTIwNzIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjEyNzQ0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoxMzQxNiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MTQwODgsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjE0NzYwLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoxNTQzMiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MTYxMDQsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjE2Nzc2LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoxNzQ0OCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MTgxMjAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjE4NzkyLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoxOTQ2NCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MjAxMzYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjIwODA4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoyMTQ4MCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MjIxNTIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjIyODI0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoyMzQ5NiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MjQxNjgsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjI0ODQwLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoyNTUxMiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MjYxODQsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjI2ODU2LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoyNzUyOCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MjgyMDAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjI4ODcyLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjoyOTU0NCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MzAyMTYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjMwODg4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjozMTU2MCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MzIyMzIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjMyOTA0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjozMzU3NiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MzQyNDgsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjM0OTIwLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjozNTU5MiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MzYyNjQsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjM2OTM2LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjozNzYwOCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6MzgyODAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjM4OTUyLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0IjozOTYyNCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDAyOTYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjQwOTY4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo0MTY0MCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDIzMTIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjQyOTg0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo0MzY1NiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDQzMjgsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjQ1MDAwLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo0NTY3MiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDYzNDQsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjQ3MDE2LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo0NzY4OCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NDgzNjAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjQ5MDMyLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo0OTcwNCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NTAzNzYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjUxMDQ4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo1MTcyMCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NTIzOTIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjUzMDY0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo1MzczNiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NTQ0MDgsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjU1MDgwLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo1NTc1MiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NTY0MjQsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjU3MDk2LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo1Nzc2OCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NTg0NDAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjU5MTEyLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo1OTc4NCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NjA0NTYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjYxMTI4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo2MTgwMCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NjI0NzIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjYzMTQ0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo2MzgxNiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NjQ0ODgsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjY1MTYwLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo2NTgzMiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NjY1MDQsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjY3MTc2LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo2Nzg0OCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6Njg1MjAsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjY5MTkyLCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo2OTg2NCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NzA1MzYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjcxMjA4LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo3MTg4MCwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVMZW5ndGgiOjY3MiwiYnl0ZU9mZnNldCI6NzI1NTIsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlTGVuZ3RoIjo2NzIsImJ5dGVPZmZzZXQiOjczMjI0LCJ0YXJnZXQiOjM0OTYyfSx7ImJ1ZmZlciI6MCwiYnl0ZUxlbmd0aCI6NjcyLCJieXRlT2Zmc2V0Ijo3Mzg5NiwidGFyZ2V0IjozNDk2Mn1dLCJidWZmZXJzIjpbeyJieXRlTGVuZ3RoIjo3NDU2OH1dfUgjAQBCSU4AhevRvo/C9b6F69E+hevRvoXr0b6PwvU+j8L1voXr0b6F69E+hOvRvkBD675AQ+s+upzmvrqc5r66nOY+QEPrvoTr0b5AQ+s+QEPrvkBD676E69E+hevRvoXr0T6PwvU+hevRvo/C9T6F69E+j8L1voXr0T6F69E+hOvRvkBD6z5AQ+s+upzmvrqc5j66nOY+QEPrvkBD6z6E69E+QEPrvoTr0T5AQ+s+hevRvo/C9b6F69G+j8L1voXr0b6F69G+hevRvoXr0b6PwvW+QEPrvkBD676E69G+upzmvrqc5r66nOa+QEPrvoTr0b5AQ+u+hOvRvkBD675AQ+u+hevRvo/C9T6F69G+hevRvoXr0T6PwvW+j8L1voXr0T6F69G+hOvRvkBD6z5AQ+u+upzmvrqc5j66nOa+QEPrvoTr0T5AQ+u+QEPrvkBD6z6E69G+hevRPo/C9b6F69E+j8L1PoXr0b6F69E+hevRPoXr0b6PwvU+QEPrPkBD676E69E+upzmPrqc5r66nOY+QEPrPoTr0b5AQ+s+hOvRPkBD675AQ+s+hevRPo/C9T6F69E+hevRPoXr0T6PwvU+j8L1PoXr0T6F69E+hOvRPkBD6z5AQ+s+upzmPrqc5j66nOY+QEPrPoTr0T5AQ+s+QEPrPkBD6z6E69E+hevRPo/C9b6F69G+hevRPoXr0b6PwvW+j8L1PoXr0b6F69G+hOvRPkBD675AQ+u+upzmPrqc5r66nOa+QEPrPoTr0b5AQ+u+QEPrPkBD676E69G+hevRPo/C9T6F69G+j8L1PoXr0T6F69G+hevRPoXr0T6PwvW+QEPrPkBD6z6E69G+upzmPrqc5j66nOa+QEPrPoTr0T5AQ+u+hOvRPkBD6z5AQ+u+vrM3vsWfd7++szc+vrM3vr6zN77Fn3c/xZ93v76zN76+szc+tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+vrM3vr6zNz7Fn3c/vrM3vsWfdz++szc+xZ93v76zNz6+szc+tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/vrM3vsWfd7++sze+xZ93v76zN76+sze+vrM3vr6zN77Fn3e/ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vrM3vr6zNz7Fn3e/xZ93v76zNz6+sze+tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+xZ93P76zN76+szc+vrM3Pr6zN77Fn3c/ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vrM3Pr6zNz7Fn3c/xZ93P76zNz6+szc+tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vrM3Pr6zN77Fn3e/xZ93P76zN76+sze+tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+xZ93P76zNz6+sze+vrM3Pr6zNz7Fn3e/ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/HgAkAAcAHgAHAAEALAAyACUALAAlAB0AMQAVAAgAMQAIACMAAgAJABcAAgAXAA8AEAAWADMAEAAzACsAAAADAAQAAAAEAAYAAQAFAAQAAQAEAAMAAgAGAAQAAgAEAAUABwAKAAsABwALAA0ACAAMAAsACAALAAoACQANAAsACQALAAwADgARABIADgASABQADwATABIADwASABEAEAAUABIAEAASABMAFQAYABkAFQAZABsAFgAaABkAFgAZABgAFwAbABkAFwAZABoAHAAfACAAHAAgACIAHQAhACAAHQAgAB8AHgAiACAAHgAgACEAIwAmACcAIwAnACkAJAAoACcAJAAnACYAJQApACcAJQAnACgAKgAtAC4AKgAuADAAKwAvAC4AKwAuAC0ALAAwAC4ALAAuAC8AMQA0ADUAMQA1ADcAMgA2ADUAMgA1ADQAMwA3ADUAMwA1ADYADgAAAAYADgAGABEAEQAGAAIAEQACAA8AAQAHAA0AAQANAAUABQANAAkABQAJAAIACAAVABsACAAbAAwADAAbABcADAAXAAkAFgAQABMAFgATABoAGgATAA8AGgAPABcAKgAOABQAKgAUAC0ALQAUABAALQAQACsAFQAxADcAFQA3ABgAGAA3ADMAGAAzABYAMgAsAC8AMgAvADYANgAvACsANgArADMAHAAqADAAHAAwAB8AHwAwACwAHwAsAB0AMQAjACkAMQApADQANAApACUANAAlADIAJAAeACEAJAAhACgAKAAhAB0AKAAdACUAAAAcACIAAAAiAAMAAwAiAB4AAwAeAAEAIwAIAAoAIwAKACYAJgAKAAcAJgAHACQADgAqABwADgAcAAAAMzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/MzOzvs3MzL6OwvW8MzOzvjMzs74K16M8zczMvjMzs76QwvW8NDOzvk1Nxb7ce6877frBvu36wb7gb5S6TU3FvjQzs77ce687TU3Fvk1Nxb6PwvW8MzOzvjMzsz4K16M8MzOzvs3MzD6QwvW8zczMvjMzsz6OwvW8NDOzvk1NxT7ce6877frBvu36wT7gb5S6TU3Fvk1NxT6PwvW8TU3FvjQzsz7ce687MzOzvs3MzL6QwvU8zczMvjMzs76OwvU8MzOzvjMzs74K16O8TU3Fvk1Nxb6PwvU87frBvu36wb7gb5Q6TU3FvjQzs77ce6+7NDOzvk1Nxb7ce6+7MzOzvs3MzD6OwvU8MzOzvjMzsz4K16O8zczMvjMzsz6QwvU8NDOzvk1NxT7ce6+77frBvu36wT7gb5Q6TU3FvjQzsz7ce6+7TU3Fvk1NxT6PwvU8MzOzPs3MzL6QwvW8zczMPjMzs76OwvW8MzOzPjMzs74K16M8TU3FPk1Nxb6PwvW87frBPu36wb7gb5S6TU3FPjQzs77ce687NDOzPk1Nxb7ce687MzOzPs3MzD6OwvW8MzOzPjMzsz4K16M8zczMPjMzsz6QwvW8NDOzPk1NxT7ce6877frBPu36wT7gb5S6TU3FPjQzsz7ce687TU3FPk1NxT6PwvW8MzOzPs3MzL6OwvU8MzOzPjMzs74K16O8zczMPjMzs76QwvU8NDOzPk1Nxb7ce6+77frBPu36wb7gb5Q6TU3FPjQzs77ce6+7TU3FPk1Nxb6PwvU8MzOzPs3MzD6QwvU8zczMPjMzsz6OwvU8MzOzPjMzsz4K16O8TU3FPk1NxT6PwvU87frBPu36wT7gb5Q6TU3FPjQzsz7ce6+7NDOzPk1NxT7ce6+7vLv9PWiWjD64G3Q/vrM3vr6zN77Fn3c/aJaMPry7/T24G3Q/tr0wvnpNMr96TTI/Os0TvzrNE786zRM/ek0yv7a9ML56TTI/aBmPPmgZjz5eJ2s/vrM3vr6zNz7Fn3c/vLv9PWiWjL64G3Q/aJaMPry7/b24G3Q/tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/aBmPPmgZj75eJ2s/ek0yv7a9MD56TTI/vLv9PWiWjD64G3S/aJaMPry7/T24G3S/vrM3vr6zN77Fn3e/aBmPPmgZjz5eJ2u/Os0TvzrNE786zRO/ek0yv7a9ML56TTK/tr0wvnpNMr96TTK/vLv9PWiWjL64G3S/vrM3vr6zNz7Fn3e/aJaMPry7/b24G3S/tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/aBmPPmgZj75eJ2u/vLv9vWiWjD64G3Q/aJaMvry7/T24G3Q/vrM3Pr6zN77Fn3c/aBmPvmgZjz5eJ2s/Os0TPzrNE786zRM/ek0yP7a9ML56TTI/tr0wPnpNMr96TTI/vLv9vWiWjL64G3Q/vrM3Pr6zNz7Fn3c/aJaMvry7/b24G3Q/tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/aBmPvmgZj75eJ2s/vLv9vWiWjD64G3S/vrM3Pr6zN77Fn3e/aJaMvry7/T24G3S/tr0wPnpNMr96TTK/Os0TPzrNE786zRO/ek0yP7a9ML56TTK/aBmPvmgZjz5eJ2u/vLv9vWiWjL64G3S/aJaMvry7/b24G3S/vrM3Pr6zNz7Fn3e/aBmPvmgZj75eJ2u/Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/tr0wPnpNMj96TTK/kML1PM3MzL4zM7M+jsL1PDMzs77NzMw+CtejvDMzs74zM7M+j8L1PE1Nxb5NTcU+4G+UOu36wb7t+sE+3HuvuzQzs75NTcU+3Huvu01Nxb40M7M+kML1PDMzsz7NzMw+jsL1PM3MzD4zM7M+CtejvDMzsz4zM7M+j8L1PE1NxT5NTcU+4G+UOu36wT7t+sE+3Huvu01NxT40M7M+3HuvuzQzsz5NTcU+jsL1PM3MzL4zM7O+CtejvDMzs74zM7O+kML1PDMzs77NzMy+3Huvu01Nxb40M7O+4G+UOu36wb7t+sG+3HuvuzQzs75NTcW+j8L1PE1Nxb5NTcW+kML1PM3MzD4zM7O+jsL1PDMzsz7NzMy+CtejvDMzsz4zM7O+j8L1PE1NxT5NTcW+4G+UOu36wT7t+sG+3HuvuzQzsz5NTcW+3Huvu01NxT40M7O+jsL1vM3MzL4zM7M+CtejPDMzs74zM7M+kML1vDMzs77NzMw+3HuvO01Nxb40M7M+4G+Uuu36wb7t+sE+3HuvOzQzs75NTcU+j8L1vE1Nxb5NTcU+kML1vM3MzD4zM7M+jsL1vDMzsz7NzMw+CtejPDMzsz4zM7M+j8L1vE1NxT5NTcU+4G+Uuu36wT7t+sE+3HuvOzQzsz5NTcU+3HuvO01NxT40M7M+kML1vM3MzL4zM7O+jsL1vDMzs77NzMy+CtejPDMzs74zM7O+j8L1vE1Nxb5NTcW+4G+Uuu36wb7t+sG+3HuvOzQzs75NTcW+3HuvO01Nxb40M7O+jsL1vM3MzD4zM7O+CtejPDMzsz4zM7O+kML1vDMzsz7NzMy+3HuvO01NxT40M7O+4G+Uuu36wT7t+sG+3HuvOzQzsz5NTcW+j8L1vE1NxT5NTcW+uBt0v2iWjD68u/29uBt0v7y7/T1oloy+xZ93v76zN76+szc+Xidrv2gZjz5oGY++Os0TvzrNE786zRM/ek0yv7a9ML56TTI/ek0yv3pNMr+2vTA+uBt0v7y7/b1oloy+uBt0v2iWjL68u/29xZ93v76zNz6+szc+Xidrv2gZj75oGY++Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+ek0yv7a9MD56TTI/uBt0v2iWjD68u/09xZ93v76zN76+sze+uBt0v7y7/T1olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/ek0yv7a9ML56TTK/Xidrv2gZjz5oGY8+uBt0v2iWjL68u/09uBt0v7y7/b1olow+xZ93v76zNz6+sze+Xidrv2gZj75oGY8+Os0TvzrNEz86zRO/ek0yv7a9MD56TTK/ek0yv3pNMj+2vTC+uBt0P2iWjD68u/29xZ93P76zN76+szc+uBt0P7y7/T1oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/ek0yP7a9ML56TTI/XidrP2gZjz5oGY++uBt0P2iWjL68u/29uBt0P7y7/b1oloy+xZ93P76zNz6+szc+XidrP2gZj75oGY++Os0TPzrNEz86zRM/ek0yP7a9MD56TTI/ek0yP3pNMj+2vTA+uBt0P2iWjD68u/09uBt0P7y7/T1olow+xZ93P76zN76+sze+XidrP2gZjz5oGY8+Os0TPzrNE786zRO/ek0yP7a9ML56TTK/ek0yP3pNMr+2vTC+uBt0P2iWjL68u/09xZ93P76zNz6+sze+uBt0P7y7/b1olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/ek0yP7a9MD56TTK/XidrP2gZj75oGY8+MzOzvgrXo7wzM7M+MzOzvpDC9TzNzMw+zczMvo7C9TwzM7M+NDOzvtx7r7tNTcU+7frBvuBvlDrt+sE+TU3Fvo/C9TxNTcU+TU3Fvtx7r7s0M7M+MzOzvo7C9bzNzMw+MzOzvgrXozwzM7M+zczMvpDC9bwzM7M+NDOzvtx7rztNTcU+7frBvuBvlLrt+sE+TU3Fvtx7rzs0M7M+TU3Fvo/C9bxNTcU+MzOzvgrXo7wzM7O+zczMvpDC9TwzM7O+MzOzvo7C9TzNzMy+TU3Fvtx7r7s0M7O+7frBvuBvlDrt+sG+TU3Fvo/C9TxNTcW+NDOzvtx7r7tNTcW+MzOzvgrXozwzM7O+MzOzvpDC9bzNzMy+zczMvo7C9bwzM7O+NDOzvtx7rztNTcW+7frBvuBvlLrt+sG+TU3Fvo/C9bxNTcW+TU3Fvtx7rzs0M7O+MzOzPgrXo7wzM7M+zczMPpDC9TwzM7M+MzOzPo7C9TzNzMw+TU3FPtx7r7s0M7M+7frBPuBvlDrt+sE+TU3FPo/C9TxNTcU+NDOzPtx7r7tNTcU+MzOzPgrXozwzM7M+MzOzPpDC9bzNzMw+zczMPo7C9bwzM7M+NDOzPtx7rztNTcU+7frBPuBvlLrt+sE+TU3FPo/C9bxNTcU+TU3FPtx7rzs0M7M+MzOzPgrXo7wzM7O+MzOzPpDC9TzNzMy+zczMPo7C9TwzM7O+NDOzPtx7r7tNTcW+7frBPuBvlDrt+sG+TU3FPo/C9TxNTcW+TU3FPtx7r7s0M7O+MzOzPgrXozwzM7O+zczMPpDC9bwzM7O+MzOzPo7C9bzNzMy+TU3FPtx7rzs0M7O+7frBPuBvlLrt+sG+TU3FPo/C9bxNTcW+NDOzPtx7rztNTcW+vrM3vsWfd7++szc+vLv9PbgbdL9oloy+aJaMPrgbdL+8u/29tr0wvnpNMr96TTI/Os0TvzrNE786zRM/aBmPPl4na79oGY++ek0yv3pNMr+2vTA+vLv9PbgbdD9oloy+vrM3vsWfdz++szc+aJaMPrgbdD+8u/29tr0wvnpNMj96TTI/Os0TvzrNEz86zRM/ek0yv3pNMj+2vTA+aBmPPl4naz9oGY++vrM3vsWfd7++sze+aJaMPrgbdL+8u/09vLv9PbgbdL9olow+ek0yv3pNMr+2vTC+Os0TvzrNE786zRO/aBmPPl4na79oGY8+tr0wvnpNMr96TTK/vrM3vsWfdz++sze+vLv9PbgbdD9olow+aJaMPrgbdD+8u/09tr0wvnpNMj96TTK/Os0TvzrNEz86zRO/aBmPPl4naz9oGY8+ek0yv3pNMj+2vTC+vrM3PsWfd7++szc+aJaMvrgbdL+8u/29vLv9vbgbdL9oloy+ek0yP3pNMr+2vTA+Os0TPzrNE786zRM/aBmPvl4na79oGY++tr0wPnpNMr96TTI/vrM3PsWfdz++szc+vLv9vbgbdD9oloy+aJaMvrgbdD+8u/29tr0wPnpNMj96TTI/Os0TPzrNEz86zRM/aBmPvl4naz9oGY++ek0yP3pNMj+2vTA+vrM3PsWfd7++sze+vLv9vbgbdL9olow+aJaMvrgbdL+8u/09tr0wPnpNMr96TTK/Os0TPzrNE786zRO/aBmPvl4na79oGY8+ek0yP3pNMr+2vTC+vrM3PsWfdz++sze+aJaMvrgbdD+8u/09vLv9vbgbdD9olow+ek0yP3pNMj+2vTC+Os0TPzrNEz86zRO/aBmPvl4naz9oGY8+tr0wPnpNMj96TTK/";var Vo=new js,bi=new xt(40,window.innerWidth/window.innerHeight,.1,100);function pf(){let i=yi.degToRad(bi.fov/2),e=Math.atan(Math.tan(i)*bi.aspect);return 2.6/Math.sin(Math.min(i,e))/.78}var ti=pf(),Tn=ti,rn=Tn,Fo=ti*.55,Bo=ti*2;bi.position.set(0,0,Tn);var Tt=new Co({antialias:!1,alpha:!1,powerPreference:"high-performance"});Tt.setPixelRatio(1);Tt.setSize(window.innerWidth,window.innerHeight);Tt.domElement.style.display="block";Tt.domElement.style.touchAction="none";document.body.style.margin="0";document.body.style.overflow="hidden";document.body.style.background="#111";document.body.appendChild(Tt.domElement);var Us=new jt;Vo.add(Us);var Ng=1.9,Dg=1.2;Vo.add(new Mr(16777215,Ng));var mf=new Oi(16777215,Dg);mf.position.set(3,5,6);Vo.add(mf);var Mf=new ln({color:1118481}),Zl={U:new ln({color:16777215}),R:new ln({color:15022389}),F:new ln({color:3058255}),D:new ln({color:16770560}),L:new ln({color:16747520}),B:new ln({color:1402304}),"?":new ln({color:13358047})},Do=new Map,Oo=null,ql=null;function Og(i){let e=atob(i),t=new Uint8Array(e.length);for(let n=0;n<e.length;n++)t[n]=e.charCodeAt(n);return t.buffer}var Ug=[{face:"U",position:(i,e)=>[e-1,1,i-1]},{face:"R",position:(i,e)=>[1,1-i,1-e]},{face:"F",position:(i,e)=>[e-1,1-i,1]},{face:"D",position:(i,e)=>[e-1,-1,1-i]},{face:"L",position:(i,e)=>[-1,1-i,e-1]},{face:"B",position:(i,e)=>[1-e,1-i,-1]}];function Fg(i){i.scene.traverse(e=>{if(!e.isMesh)return;if(/^body(?:_|$)/.test(e.name)){e.material=Mf;return}let t=/^sticker_([URFDLB])(?:_|$)/.exec(e.name),n=e.parent&&/^cubie_(\d)(\d)(\d)$/.exec(e.parent.name);if(!t||!n)return;let s=[n[1],n[2],n[3]].map(r=>Number(r)-1).join(",");e.material=Zl[t[1]],Do.has(s)||Do.set(s,{}),Do.get(s)[t[1]]=e}),Us.add(i.scene),Oo=Ug.flatMap(({face:e,position:t})=>Array.from({length:9},(n,s)=>{let r=t(Math.floor(s/3),s%3).join(",");return Do.get(r)[e]})),ql&&gf(ql),Ot()}new Po().parse(Og(df),"",Fg,i=>console.error("Failed to parse rubik.glb",i));function gf(i){if(!Oo)return;let e=!1;for(let t=0;t<54;t++){let n=Zl[i[t]];Oo[t].material!==n&&(Oo[t].material=n,e=!0)}e&&Ot()}window.setCubeState=i=>typeof i!="string"||!/^[URFDLB?]{54}$/.test(i)?!1:(ql=i,gf(i),!0);window.setRubikWireframe=i=>{Mf.wireframe=!!i;for(let e of Object.values(Zl))e.wireframe=!!i;Ot()};var Pr=-.35,Lr=.55,Go=Pr,Ho=Lr;Us.rotation.x=Pr;Us.rotation.y=Lr;var ko=.008,En=!1,Hi=0,Wi=0,Os=null,Uo=0,Yl=!1,Kt=new Map,ni=null;function Bg(){Tt.render(Vo,bi)}function kg(){return Math.abs(Go-Pr)>.001||Math.abs(Ho-Lr)>.001||Math.abs(rn-Tn)>.005}function Ot(){Os!==null||Yl||document.hidden||(Os=requestAnimationFrame(Vg))}function Vg(i){Os=null;let e=Uo?Math.min(i-Uo,50):16.7;Uo=i,Pr=Go,Lr=Ho,Tn+=(rn-Tn)*(1-Math.exp(-e/45)),Math.abs(rn-Tn)<=.005&&(Tn=rn),Us.rotation.x=Pr,Us.rotation.y=Lr,bi.position.z=Tn,Bg(),kg()&&Ot()}Tt.domElement.addEventListener("pointerdown",i=>{i.pointerType!=="touch"&&(En=!0,Hi=i.clientX,Wi=i.clientY,Tt.domElement.setPointerCapture(i.pointerId),Ot())});Tt.domElement.addEventListener("pointermove",i=>{if(i.pointerType==="touch"||!En)return;let e=i.clientX-Hi,t=i.clientY-Wi;Ho+=e*ko,Go+=t*ko,Hi=i.clientX,Wi=i.clientY,Ot()});function _f(i){if(i.pointerType!=="touch"){En=!1;try{Tt.domElement.releasePointerCapture(i.pointerId)}catch{}Ot()}}Tt.domElement.addEventListener("pointerup",_f);Tt.domElement.addEventListener("pointercancel",_f);Tt.domElement.addEventListener("lostpointercapture",()=>{En=!1});Tt.domElement.addEventListener("wheel",i=>{i.preventDefault(),rn+=i.deltaY*.005,rn=yi.clamp(rn,Fo,Bo),Ot()},{passive:!1});function xf(){let i=[...Kt.values()];if(i.length<2)return null;let e=i[0].x-i[1].x,t=i[0].y-i[1].y;return Math.hypot(e,t)}Tt.domElement.addEventListener("touchstart",i=>{i.preventDefault();for(let e of i.changedTouches)Kt.set(e.identifier,{x:e.clientX,y:e.clientY});if(Kt.size===1){let e=[...Kt.values()][0];En=!0,Hi=e.x,Wi=e.y,ni=null}Kt.size>=2&&(En=!1,ni=xf()),Ot()},{passive:!1});Tt.domElement.addEventListener("touchmove",i=>{i.preventDefault();for(let e of i.changedTouches)Kt.set(e.identifier,{x:e.clientX,y:e.clientY});if(Kt.size===1){let e=[...Kt.values()][0],t=e.x-Hi,n=e.y-Wi;Ho+=t*ko,Go+=n*ko,Hi=e.x,Wi=e.y,En=!0,ni=null}if(Kt.size>=2){En=!1;let e=xf();if(ni!==null&&e!==null){let t=e-ni;rn-=t*ti*.0014,rn=yi.clamp(rn,Fo,Bo)}ni=e,Tn=rn}Ot()},{passive:!1});function yf(i){i.preventDefault();for(let e of i.changedTouches)Kt.delete(e.identifier);if(Kt.size===0)En=!1,ni=null;else if(Kt.size===1){ni=null,En=!0;let e=[...Kt.values()][0];Hi=e.x,Wi=e.y}Ot()}Tt.domElement.addEventListener("touchend",yf,{passive:!1});Tt.domElement.addEventListener("touchcancel",yf,{passive:!1});function vf(){En=!1,ni=null,Kt.clear()}function Kl(){vf(),Os!==null&&cancelAnimationFrame(Os),Os=null,Uo=0}window.setRubikActive=i=>{Yl=!i,Yl?Kl():Ot()};window.addEventListener("blur",vf);document.addEventListener("visibilitychange",()=>{document.hidden?Kl():Ot()});function Gg(){bi.aspect=window.innerWidth/window.innerHeight,bi.updateProjectionMatrix();let i=rn/ti;ti=pf(),Fo=ti*.55,Bo=ti*2,Tn=rn=yi.clamp(ti*i,Fo,Bo),bi.position.z=Tn,Tt.setSize(window.innerWidth,window.innerHeight),Ot()}window.addEventListener("resize",Gg);window.addEventListener("pagehide",Kl);window.addEventListener("pageshow",Ot);Ot();})();
/*! Bundled license information:

three/build/three.core.js:
three/build/three.module.js:
  (**
   * @license
   * Copyright 2010-2026 Three.js Authors
   * SPDX-License-Identifier: MIT
   *)
*/
