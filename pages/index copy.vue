<template>
  <div>
    <div>CHƠI GAME GHÉP HÌNH 3 x 3</div>
    <div class="info-user-turn">
      <p>Time [mm:ss]: {{ playTime }}</p>
      <NuxtTime :datetime="Date.now()" second="numeric" month="long" day="numeric" />
    </div>
    <button id="start" @click="playGame()" v-if="theFirstTime">Bắt đầu</button>
    <PlayAgain
      :showModal="showModal"
      :title="titleModalPlayAgain"
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
      playTime: "00:00",
      autoGen: {},
    }
  },
  computed: {
    formattedPlayTime() {
      const minutes = Math.floor(this.currentTime / 60);
      const seconds = this.currentTime % 60;
      return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }
  },
  mounted() {
    window.addEventListener('resize', this.resizeHandler)
    this.theFirstTime = false
    this.isShowAwser = true;
    this.loadImageAndDrawPuzzle()
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeHandler)
    clearInterval(this.timerInterval);
  },
  methods: {
    playGame() {
      // Update for another time
      this.theFirstTime = false
      this.isShowAwser = true;
      this.loadImageAndDrawPuzzle()
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
      this.showModal = false
      console.log('PLAY AGAIN')
      this.loadImageAndDrawPuzzle()
    },
    cancelPlayAgain() {
      this.showModal = false
      let url = '/home'
      this.$router.push(url)
    },
    endGame(result) {
      if (result) this.titleModalPlayAgain = 'Congratulations!'
      else this.titleModalPlayAgain = 'Good luck another time!'
      this.showModal = true
    },
    loadImageAndDrawPuzzle() {
      let malharro = new Image()
      malharro.src = require('~/static/malharro.jpg')
      malharro.onload = () => {
        this.drawPuzzle(malharro)
      }
    },
    drawPuzzle(image) {
      let painterKonva = new headbreaker.painters.Konva();
      const containerWidth = document.querySelector('.puzzle-container').clientWidth;
      const containerHeight = document.querySelector('.puzzle-container').clientHeight;
      const pieceSize = Math.min(containerWidth, containerHeight) / 4.6; // Điều chỉnh để có khoảng cách tương đối giữa các mảnh ghép

      this.autoGen = new headbreaker.Canvas('puzzle', {
        width: containerWidth,
        height: containerHeight,
        pieceSize: pieceSize,
        proximity: pieceSize * 0.13, // Đặt khoảng cách tương đối giữa các mảnh ghép
        borderFill: pieceSize * 0.09, // Đặt khoảng cách tương đối giữa các mảnh ghép
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
        horizontalPiecesCount: 3,
        verticalPiecesCount: 3,
      });

      this.autoGen.shuffleGrid();
      this.autoGen.attachSolvedValidator();
      this.autoGen.onValid(() => {
        setTimeout(() => {
          this.isComplete = true;
          this.endGame(this.isComplete);
        }, 500);
      });

      this.autoGen.draw();
      const puzzle = this.autoGen.puzzle;
      puzzle['dragMode']['dragShouldDisconnect'] = function (piece, dx, dy) {
        console.log(piece, dx, dy);
        return piece.horizontalConnector.openMovement(piece, dx) && piece.verticalConnector.openMovement(piece, dy);
      };
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
