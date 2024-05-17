<template>
  <div>
    <div>CHƠI GAME GHÉP HÌNH 3 x 3</div>
    <div class="info-user-turn">
      <p>Time [mm:ss]: {{ formattedPlayTime }}</p>
    </div>
    <button id="start" @click="playGame()" v-if="theFirstTime">Bắt đầu</button>
    <PlayAgain
      :showModal="showModal"
      :title="titleModalPlayAgain"
      :timeComplete="timeComplete"
      @play="playAgain"
      @cancel="cancelPlayAgain"
    />
    <div class="container">
      <div id="puzzle" class="puzzle-container"></div>
    </div>
  </div>
</template>

<script>
import headbreaker from 'headbreaker'

export default {
  layout: 'default',
  modules: ['nuxt-time'],
  data() {
    return {
      theFirstTime: true,
      isShowAwser: false,
      isComplete: false,
      showModal: false,
      titleModalPlayAgain: '',
      startTime: null,
      currentTime: 0,
      currentTimeString: "",
      timeComplete: "",
      timerInterval: null,
      autoGen: {},
    }
  },
  computed: {
    formattedPlayTime() {
      const minutes = Math.floor(this.currentTime / 60);
      const seconds = this.currentTime % 60;
      this.currentTimeString = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
      return this.currentTimeString;
    }
  },
  mounted() {
    window.addEventListener('resize', this.resizeHandler)
    this.isShowAwser = true;
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeHandler)
    clearInterval(this.timerInterval);
  },
  methods: {
    playGame() {
      this.theFirstTime = false;
      this.isShowAwser = true;
      this.startTimer();
      this.loadImageAndDrawPuzzle();
    },
    startTimer() {
      this.startTime = Date.now();
      this.currentTime = 0;
      if (this.timerInterval) clearInterval(this.timerInterval);
      this.timerInterval = setInterval(() => {
        this.currentTime = Math.floor((Date.now() - this.startTime) / 1000);
      }, 1000);
    },
    stopTimer() {
      this.timeComplete = this.currentTimeString;
      if (this.timerInterval) clearInterval(this.timerInterval);
    },
    resizeHandler() {
      const container = document.getElementById('puzzle');
      const containerRect = container.getBoundingClientRect();
      const newWidth = containerRect.width;
      const newHeight = containerRect.height;

      this.autoGen.setSize(newWidth, newHeight);
      this.autoGen.redraw();
    },
    playAgain() {
      this.showModal = false;
      this.loadImageAndDrawPuzzle();
      this.startTimer();
    },
    cancelPlayAgain() {
      this.showModal = false;
      let url = '/home';
      this.$router.push(url);
    },
    endGame(result) {
      this.stopTimer();
      this.titleModalPlayAgain = result ? 'Congratulations!' : 'Good luck another time!';
      this.showModal = true;
    },
    loadImageAndDrawPuzzle() {
      let malharro = new Image();
      malharro.src = require('~/static/malharro.jpg');
      malharro.onload = () => {
        this.drawPuzzle(malharro);
      }
    },
    drawPuzzle(image) {
      let painterKonva = new headbreaker.painters.Konva();
      const containerWidth = document.querySelector('.puzzle-container').clientWidth;
      const containerHeight = document.querySelector('.puzzle-container').clientHeight;
      const pieceSize = Math.min(containerWidth, containerHeight) / 4.6;

      this.autoGen = new headbreaker.Canvas('puzzle', {
        width: containerWidth,
        height: containerHeight,
        pieceSize: pieceSize,
        proximity: pieceSize * 0.13,
        borderFill: pieceSize * 0.09,
        strokeWidth: 6,
        lineSoftness: 0.18,
        image: image,
        fixed: true,
        preventOffstageDrag: true,
        painter: painterKonva,
        maxPiecesCount: 6
      });

      this.autoGen.adjustImagesToPuzzleHeight();
      this.autoGen.autogenerate({
        horizontalPiecesCount: 2,
        verticalPiecesCount: 2,
        // horizontalPiecesCount: 3,
        // verticalPiecesCount: 3,
      });

      this.autoGen.shuffleGrid();
      this.autoGen.attachSolvedValidator();
      this.autoGen.onValid(() => {
        this.stopTimer();
        setTimeout(() => {
          this.isComplete = true;
          this.endGame(this.isComplete);
        }, 500);
      });

      this.autoGen.draw();
    },
  },
}
</script>

<style scoped>
.puzzle-container {
  position: relative;
  width: 95vw;
  height: 90vh;
  margin: 0 auto;
}
#puzzle .konvajs-content canvas {
  border: solid !important;
}
</style>
