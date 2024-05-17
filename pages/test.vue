<template>
  <div>
    <div>CHƠI GAME GHÉP HÌNH 3 x 3</div>
    <div class="info-user-turn">
      <p>Time [mm:ss]: {{ playTime }}</p>
    </div>
    <button id="start" @click="playGame()" v-if="theFirstTime">Bắt đầu</button>
    <PlayAgain
      :showModal="showModal"
      :title="titleModalPlayAgain"
      @play="playAgain"
      @cancel="cancelPlayAgain"
    />
    <div class="container">
      <div id="puzzle"></div>
    </div>

  </div>
</template>

<script>
import headbreaker from 'headbreaker'

export default {
  layout: 'default',
  data() {
    return {
      theFirstTime: true,
      isShowAwser: false,
      isComplete: false,
      showModal: false,
      titleModalPlayAgain: '',
      initialWidth: 1200,
      initialHeight: 900,
      autoGen: {},
      playTime: "00:00",
    }
  },
  mounted() {
    window.addEventListener('resize', this.resizeHandler)
        this.theFirstTime = false
      this.isShowAwser = true;

      this.loadImageAndDrawPuzzle()
  },
  methods: {
    playGame() {
      // Update for another time
      this.theFirstTime = false
      this.isShowAwser = true;

      this.loadImageAndDrawPuzzle()
    },

    resizeHandler(e) {
      var container = document.getElementById('puzzle')
      this.autoGen.scale(container.offsetWidth / this.initialWidth)
      this.autoGen.redraw()
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

      this.autoGen = new headbreaker.Canvas('puzzle', {
        width: this.initialWidth,
        height: this.initialHeight,
        pieceSize: 100,
        proximity: 20,
        borderFill: 10,
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
        verticalPiecesCount: 2,
      })

      this.autoGen.shuffleGrid()

      this.autoGen.attachSolvedValidator()
      this.autoGen.onValid(() => {
        setTimeout(() => {
          this.isComplete = true
          this.endGame(this.isComplete)
        }, 500)
      })

      this.autoGen.draw()

        const puzzle = this.autoGen.puzzle;
        puzzle['dragMode']['dragShouldDisconnect'] = ( function (piece, dx, dy) {
            console.log(piece, dx, dy)
            return piece.horizontalConnector.openMovement(piece, dx) && piece.verticalConnector.openMovement(piece, dy);
        } )
    },
  },
}
</script>

<style lang="css" scoped>

#puzzle .konvajs-content canvas {
    border: solid !important;
}

</style>
