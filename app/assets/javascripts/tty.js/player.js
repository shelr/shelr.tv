"use strict;"

if (window) {
  window.VT = (typeof VT === 'undefined' ? {} : window.VT);
} else {
  var VT = {};
}

VT.Player = function(term) {
  this.term    = term;
  this.data    = null;
  this.timing  = null;
  this.element = document.getElementById('player');
  this.el = $(this.element);
  this.speedup = 1;
  this.calculateTermSize();
  this.initSpeedControl();
  this.initHover();
  this.initTermContainer();
  this.initHeader();
  this.initProgress();
  this.initControls();
  this.initCmdline();
}

VT.Player.prototype.onError = function() {
  this.pause();
  // this.term.clear();
  this.hoverShow();
  this.hover.classList.add('error');
  this.hoverHide = function() {};
  this.hover.innerHTML = "<br/><div class='img'><img src='/assets/harakiri.png' alt='So sorry...'/></div>切腹"
  this.hover.innerHTML += "<p>Sorry we cannot emulate this shellcast in HTML.<br/>" +
    "Use commandline client instead!<br/>" +
    "<span class='donate'> And consider small <a href='http://weusecoins.com' target='_blank'>bitcoin</a> " +
    "donation to fix this: 17tKDsdjKiS9bmnpH93NBeJnykWgLYbntL  </span>  <br/> &darr; &darr; &darr;</p>"
  this.cmdline.classList.remove('hidden');
  this.controls.classList.add('hidden');
}

VT.Player.prototype.initSpeedControl = function() {
  var speed = jQuery('.speed');
  var player = this;
  speed.change(function(e) {
  })
  fdSlider.createSlider({
    inp: document.getElementsByClassName("speed")[0],
    value: 2.5,
    step:0.5,
    maxStep:1,
    min:1,
    max:10,
    animation: 'tween',
    hideInput: true,
    forceValue: true,
    callbacks: {
      update: [function (update) {
        player.speedup = update.value;
      }]
    }
  });
}

VT.Player.prototype.jumpTo = function(position) {
}

VT.Player.prototype.initProgress = function() {
  this.progress = this.el.find('.progress');
  this.progressBar = this.progress.find('.bar');
  this.progress.click(function(e) {
    console.log(e);
  })
}

VT.Player.prototype.initControls = function() {
  this.controls = this.element.getElementsByClassName('controls')[0];
  this.controls.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.initCmdline = function() {
  this.cmdline = this.element.getElementsByClassName('cmdline')[0];
  this.cmdline.setAttribute("style", "width:" + (this.termWidth - 6) + "px");
  this.cmdline.addEventListener('click', function(e) {
    e.target.select()
  }, true)
}

VT.Player.prototype.calculateTermSize = function() {
  this.termWidth = (this.term.cols * 7);
  this.termHeight = (this.term.rows * 13);
  this.element.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.initHeader = function() {
  this.header = this.element.getElementsByClassName('header')[0];
  this.header.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.initTermContainer = function() {
  var term = document.getElementById('term');
  term.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.load = function(path) {
  var player = this;
  jQuery.get(path).success(function(resp){
    player.record = resp;
    player.setTiming(player.record.timing);
    player.setData(player.record.typescript);
    player.createTimeline();
    player.enableButtons();
  }).error(function (resp) { console.log("Error downloading record:", resp) });
}

VT.Player.prototype.setTiming = function(data) {
  var timing = [];
  data.split("\n").forEach(function(line){
    var timeBytes = line.split(" ");
    timeBytes = [parseFloat(timeBytes[0]), parseInt(timeBytes[1])];
    if (!isNaN(timeBytes[0]) && !isNaN(timeBytes[1])) {
      timing.push(timeBytes);
    }
  })
  this.timing = timing;
}

VT.Player.prototype.setData = function(data) {
  var dArr  = data.split("\n");
  // drop first and last strings
  this.data = dArr.slice(1, dArr.length - 2).join("\n");
  this.data += "\n";
}

VT.Player.prototype.createTimeline = function(data) {
  var timeline = [];
  var data = this.data;
  var bOffset = 0;

  this.timing.forEach(function(chunk) {
    var bytes = data.slice(bOffset, bOffset += chunk[1]);
    timeline.push([chunk[0] * 1000, bytes]);
  })

  this.timeline = timeline;
  this.progress.prop('max', timeline.length);
  this.setProgress(0);
}

VT.Player.prototype.enableButtons = function(data) {
  var button;
  var player = this;
  this.buttons = this.element.getElementsByClassName('sc-button');
  for (var i = 0; i < this.buttons.length; i++) {
    button = this.buttons[i];
    button.addEventListener('click', function(ev){
      var action = ev.currentTarget.getAttribute('data-action');
      if (action) player[action]();
    }, true);
    button.removeAttribute('disabled');
  }
}

VT.Player.prototype.play = function() {
  var player = this;
  var button = this.element.getElementsByClassName('toggle')[0];
  button.setAttribute('data-action', 'pause');
  button.getElementsByTagName('img')[0].setAttribute('src', '/assets/term/playback-pause.png');

  player.hoverHide();

  if (player.playing) return;
  // if (player.timelinePosition == 0) player.term.t;

  player.playing = true;

  function scheduleChunked(timeline) {
    var chunk = timeline[player.timelinePosition];
    var debug = 0;
    var txt;
    if (chunk && player.playing) {
      txt = chunk[1];
      player.term.write(txt)
      setTimeout(function() {
        player.updateTimelinePosition(+1);
        scheduleChunked(timeline);
      }, (chunk[0] / player.speedup));
    } else {
      if (!player.playing) {
        console.log('paused')
      } else {
        player.timelinePosition = 0;
        player.pause();
      }
      player.hoverShow();
    }
  }

  scheduleChunked(player.timeline);
}

VT.Player.prototype.pause = function() {
  var button = this.element.getElementsByClassName('toggle')[0];
  button.getElementsByTagName('img')[0].setAttribute('src', '/assets/term/playback-start.png')
  button.setAttribute('data-action', 'play');
  this.playing = false;
}

VT.Player.prototype.toggle = function() {
  this.playing ? this.pause() : this.play();
}

VT.Player.prototype.settings = function() {
  this.cmdline.classList[this.cmdline.classList.contains('hidden') ? 'remove' : 'add']('hidden');
}

VT.Player.prototype.updateTimelinePosition = function(val) {
  this.timelinePosition = this.timelinePosition + val;
  this.progressBar.css("width", ((100.0 / this.timeline.length) * this.timelinePosition) + '%' );
}

VT.Player.prototype.setProgress = function(val) {
  this.timelinePosition = val;
  this.progress.prop('value', val);
}

VT.Player.prototype.initHover = function(content) {
  // var player = this;
  this.hover = document.createElement('div');
  // this.term.element.appendChild(this.hover);

  // this.vt.canvas.container.addEventListener('mouseout', function(ev) {
  //   if (!player.playing && ev.target.classList.contains('canvas')) {
  //     //console.log(ev.target.classList)
  //     player.hoverShow();
  //   } else {
  //     ev.stopPropagation();
  //   }
  // }, false)

  // this.hover.addEventListener('mouseover', function(ev) {
  //   if (!player.playing)  {
  //     player.hoverHide();
  //   }
  // }, false);
}

VT.Player.prototype.hoverShow = function(content) {
  return true;
  if (player.playing) {
    this.hoverHide();
    return;
  }
  var offsets = this.vt.canvas.getHtmlOffsets();
  var hover  = this.hover;
  hover.classList.remove('disabled');
  hover.style.display    = 'block';
  hover.style.position   = 'absolute';
  hover.style.top    = offsets.offsetTop+5+'px';
  hover.style.left   = offsets.offsetLeft+5+'px';
  hover.style.width  = offsets.offsetWidth-10+'px';
  hover.style.height = offsets.offsetHeight-10+'px';
  hover.setAttribute('id', 'player-hover');
  hover.classList.add('enabled');
}

VT.Player.prototype.hoverHide = function() {
  this.hover.style.width  = 0;
  this.hover.style.height = 0;
  this.hover.classList.remove('enabled');
  this.hover.classList.add('disabled');
  this.hover.innerHTML = ''
}
