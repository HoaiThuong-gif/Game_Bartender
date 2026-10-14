// Short, quiet sounds only. Nothing loops or requires sound to solve a puzzle.
export class SongCuAudio {
  constructor() {
    this.context = null;
    this.master = null;
    this.enabled = false;
    this.active = false;
    this.volume = .18;
    this.sources = new Set();
    this.disposed = false;
    this.unlocked = false;
  }

  configure(snapshot) {
    this.enabled = snapshot.sound;
    this.volume = Math.min(.5, Math.max(0, snapshot.volume));
    this.active = snapshot.active;
    if (this.master && this.context.state !== 'closed') {
      this.master.gain.setTargetAtTime(this.enabled && this.active ? this.volume : 0, this.context.currentTime, .02);
    }
    if (!this.active || !this.enabled) this.pause();
    else this.unlock();
  }

  unlock() {
    if (this.disposed || !this.enabled || !this.active) return;
    try {
      if (!this.context) {
        const Audio = window.AudioContext || window.webkitAudioContext;
        if (!Audio) return;
        this.context = new Audio();
        this.master = this.context.createGain();
        this.master.gain.value = this.volume;
        this.master.connect(this.context.destination);
      }
      this.unlocked = true;
      if (this.context.state === 'suspended') {
        this.context.resume().then(() => {
          if (this.disposed || !this.active || !this.enabled) this.pause();
        }).catch(() => {});
      }
    } catch (_) { /* Audio is optional. */ }
  }

  play(kind) {
    const ctx = this.context;
    if (!ctx || !this.unlocked || !this.enabled || !this.active || this.disposed || ctx.state !== 'running') return;
    const now = ctx.currentTime;
    const tonal = ['success','on','off','signal'].includes(kind);
    const duration = kind === 'success' ? .8 : tonal ? .18 : kind === 'tap' ? .06 : kind === 'channel' ? .07 : .035;
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0, now);
    gain.gain.linearRampToValueAtTime(kind === 'success' ? .16 : kind === 'tap' ? .08 : .11, now + .008);
    gain.gain.exponentialRampToValueAtTime(.0001, now + duration);
    gain.connect(this.master);
    let source;
    const filter = ctx.createBiquadFilter();
    filter.type = 'lowpass'; filter.frequency.value = kind === 'success' ? 1100 : 650;
    filter.connect(gain);
    if (tonal) {
      source = ctx.createOscillator();
      source.type = 'sine'; source.frequency.setValueAtTime(kind==='off'?260:kind==='signal'?330:220, now);
      source.frequency.exponentialRampToValueAtTime(kind==='off'?150:kind==='success'?523.25:kind==='signal'?350:300, now + duration*.7);
    } else {
      const buffer = ctx.createBuffer(1, Math.ceil(ctx.sampleRate * duration), ctx.sampleRate);
      const values = buffer.getChannelData(0);
      for (let i = 0; i < values.length; i++) values[i] = Math.random() * 2 - 1;
      source = ctx.createBufferSource(); source.buffer = buffer;
    }
    source.connect(filter); this.sources.add(source);
    source.onended = () => {
      this.sources.delete(source); source.disconnect(); filter.disconnect(); gain.disconnect();
    };
    source.start(now); source.stop(now + duration);
  }

  pause() {
    for (const source of this.sources) { try { source.stop(); } catch (_) {} }
    this.sources.clear();
    if (this.context?.state === 'running') this.context.suspend().catch(() => {});
  }

  dispose() {
    this.disposed = true; this.pause();
    if (this.context && this.context.state !== 'closed') this.context.close().catch(() => {});
  }
}
