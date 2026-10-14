const W=640,H=480;
function box(c,x,y,w,h,color,r=10){c.fillStyle=color;c.beginPath();c.roundRect(x,y,w,h,r);c.fill();}
function house(c,x,y,scale=1){
 c.save();c.translate(x,y);c.scale(scale,scale);
 box(c,-65,-65,130,90,'#d9bc8a',2);
 c.fillStyle='#ad6c53';c.beginPath();c.moveTo(-82,-60);c.lineTo(0,-115);c.lineTo(82,-60);c.closePath();c.fill();
 box(c,-18,-32,36,57,'#567769',2);box(c,30,-40,24,27,'#688778',2);c.restore();
}
export class Programs{
 constructor(){
  this.canvas=document.createElement('canvas');this.canvas.width=W;this.canvas.height=H;this.context=this.canvas.getContext('2d');
  this.scene=document.createElement('canvas');this.scene.width=W;this.scene.height=H;
  this.noise=document.createElement('canvas');this.noise.width=160;this.noise.height=120;
  const c=this.noise.getContext('2d');let seed=73;
  for(let i=0;i<5500;i++){seed=seed*16807%2147483647;const x=seed%160;seed=seed*16807%2147483647;c.fillStyle=i%2?'#515e55':'#d3d5bf';c.fillRect(x,seed%120,2,1);}
  this.epoch=-1;this.playback=-1;this.channel=-1;this.changedAt=0;this.playStart=0;this.reported=false;this.sceneKey='';
 }
 drawScene(variant){
  const c=this.scene.getContext('2d');
  const skies=['#b9d0bc','#bac5d0','#d9bdaa','#a5b8b5'];
  box(c,0,0,W,H,skies[variant],0);
  c.fillStyle='#ead9a9';c.beginPath();c.arc(540,100,42,0,Math.PI*2);c.fill();
  box(c,0,220,W,260,'#96ae94',0);box(c,0,310,W,170,'#cbb38b',0);
  house(c,160,290,1.35);house(c,480,280,.9);
  if(variant===1){
   box(c,0,370,W,110,'#7d9f9b',0);
   c.strokeStyle='#b3c9bd';c.lineWidth=3;
   for(let i=0;i<5;i++){c.beginPath();c.moveTo(40+i*120,400+i%2*25);c.lineTo(110+i*120,400+i%2*25);c.stroke();}
  } else {
   c.strokeStyle='#827353';c.lineWidth=12;c.beginPath();c.moveTo(360,330);c.lineTo(352,155);c.stroke();
   c.fillStyle=variant===2?'#a89364':'#79936b';
   for(const [x,y,r] of [[322,158,49],[386,155,53],[352,114,55]]){c.beginPath();c.arc(x,y,r,0,Math.PI*2);c.fill();}
  }
  if(variant===3){
   box(c,65,360,510,14,'#837359',1);
   for(let i=0;i<8;i++)box(c,80+i*65,350,12,65,'#837359',1);
  }
  // A small cat belongs to the programme, rather than the surrounding UI.
  c.fillStyle='#535950';c.beginPath();c.ellipse(250,391,31,18,0,0,Math.PI*2);c.fill();
  c.beginPath();c.arc(275,369,17,0,Math.PI*2);c.fill();
  c.beginPath();c.moveTo(261,361);c.lineTo(262,345);c.lineTo(273,354);c.lineTo(286,346);c.lineTo(290,366);c.fill();
  c.strokeStyle='#535950';c.lineWidth=7;c.beginPath();c.moveTo(221,390);c.quadraticCurveTo(197,365,215,355);c.stroke();
 }
 draw(s,now,feedback={}){
  const c=this.context;box(c,0,0,W,H,'#17241f',0);
  if(!s.powered)return {animate:false};
  const channel=Math.max(0,Math.min(7,Math.round((s.controls[2]+1)*3.5)));
  const useful=channel===s.targetChannel;
  const variant=useful?s.scene:channel%4;
  const key=String(variant);
  if(key!==this.sceneKey){this.sceneKey=key;this.drawScene(variant);}
  if(this.epoch!==s.epoch){this.epoch=s.epoch;this.playback=-1;this.channel=-1;}
  if(channel!==this.channel){this.channel=channel;this.changedAt=now;}
  const switching=Math.max(0,1-(now-this.changedAt)/230);
  const q=s.needsAntennas?s.controls.slice(0,2).map((v,i)=>Math.exp(-3*(v-s.targets[i])**2)):[1,1];
  const clarity=q[0],stability=q[1];
  const snow=channel===0||(!useful&&channel%2===0);
  c.save();
  const offset=s.reduceMotion?0:Math.sin(now/210)*(1-stability)*15;
  c.globalAlpha=.6+.4*clarity;c.drawImage(this.scene,0,offset);
  c.globalAlpha=(1-clarity)*.5;c.drawImage(this.scene,35*(1-clarity),offset);
  c.restore();
  let active=-1,elapsed=0,end=0,starts=[];
  if(this.playback!==s.playback){this.playback=s.playback;this.playStart=now;this.reported=false;}
  if(useful){
   elapsed=now-this.playStart;let cursor=300;
   s.rhythm.forEach((mark,i)=>{starts.push(cursor);const length=mark==='.'?350:950;if(elapsed>=cursor&&elapsed<cursor+length)active=i;cursor+=length+550;});
   end=cursor+300;
   const length=active<0?0:s.rhythm[active]==='.'?350:950;
   const glow=active<0||!s.playing?0:Math.max(0,Math.min(1,(elapsed-starts[active])/90,(starts[active]+length-elapsed)/90));
   // The lantern is the visual message, with a gentle local glow.
   c.strokeStyle='#625f49';c.lineWidth=3;c.beginPath();c.moveTo(482,167);c.lineTo(482,205);c.stroke();
   box(c,451,205,62,74,s.complete?'#ead59a':glow?'#e5d19a':'#a99f71',18);
   c.strokeStyle='#897452';c.lineWidth=3;
   for(let x=463;x<511;x+=14){c.beginPath();c.moveTo(x,212);c.lineTo(x,270);c.stroke();}
   if(glow>0||s.complete){c.save();c.globalAlpha=s.complete?.12:glow*.16;c.fillStyle='#f4dfa4';c.beginPath();c.arc(482,242,68,0,Math.PI*2);c.fill();c.restore();}
   if(s.phase==='contact'){c.save();c.globalAlpha=s.reduceMotion?.35:.25+.2*(1+Math.sin(now/260))/2;box(c,0,0,W,H,'#233a31',0);c.restore();}
  }
  c.save();c.globalAlpha=snow?.94:Math.min(.9,(1-stability)*.72+switching*.8);
  c.imageSmoothingEnabled=false;
  const n=s.reduceMotion?0:Math.floor(now/150)%24;
  c.drawImage(this.noise,-n,-n,W+24,H+24);c.restore();
  if(!s.reduceMotion&&stability<.95){
   c.save();c.globalAlpha=(1-stability)*.3;box(c,0,(now/13)%H,W,16,'#233a31',0);c.restore();
  }
  c.save();c.globalAlpha=.05;c.fillStyle='#14231c';for(let y=0;y<H;y+=4)c.fillRect(0,y,W,1);c.restore();
  if(feedback.holding){c.save();c.globalAlpha=.13;box(c,8,8,W-16,H-16,'#e7daa6',30);c.restore();}
  if(s.playing&&useful&&elapsed>=end&&!this.reported){this.reported=true;return {animate:true,playbackEnd:s.playback};}
  return {animate:s.playing||feedback.holding||switching>0||(!s.reduceMotion&&(snow||stability<.98||s.phase==='contact'))};
 }
 hit(){return null;}
 dispose(){for(const canvas of [this.canvas,this.scene,this.noise])canvas.width=canvas.height=1;}
}

