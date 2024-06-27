<template>
  <div id="puzzle-container">
    <div id="game">
      <div>[3x3] GAME XẾP HÌNH</div>
      <div class="info-user-turn">
        <p>Thời gian tối đa [mm:ss]: {{ formattedMaxTime }}</p>
        <p>Thời gian chơi [mm:ss]: {{ formattedPlayTime }}</p>
      </div>
      <button id="start" @click="playGame()" v-if="!isPlaying">Bắt đầu</button>
      <button id="exit" @click="exitGame()" v-else>Thoát game</button>
      <div class="container">
        <div class="puzzle-contain">
          <div id="puzzle-background" class="puzzle-background"></div>
          <div id="puzzle" class="puzzle-canvas"></div>
          <div class="suggest-container">

          <div
            class="suggest-info"
            @click="targetSuggest()"
          >
            <span>Click toggle suggest</span>
            <img class="suggest-image" src="~/static/malharro.jpg" alt="" />
          </div></div>
        </div>
      </div>
    </div>

    <PlayAgain
      :showModal="showModal"
      :title="titleModalPlayAgain"
      :completeTime="completeTime"
      @play="playAgain"
      @cancel="exitGame"
    />

    <ConfirmExit
      :showModalExit="showModalExit"
      @confirmExit="actionAgreeExit"
      @cancelExit="actionRefureExit"
    />
  </div>
</template>

<script>
import headbreaker from 'headbreaker'

export default {
  layout: 'default',
  data() {
    return {
      isPlaying: false,
      isShowAwser: false,
      isComplete: false,
      showModal: false,
      showModalExit: false,
      titleModalPlayAgain: '',
      startTime: null,
      currentTime: 0,
      currentTimeString: '',
      completeTime: '',
      maxTime: 120,
      timerInterval: null,
      autoGen: {},
      pauseTime: 0,
    }
  },
  computed: {
    formattedPlayTime() {
      if (!this.currentTimeString) this.updateCurrentTimeString()

      return this.currentTimeString
    },
    formattedMaxTime() {
      return this.convertTimeToString(this.maxTime)
    },
  },
  beforeMount() {
    this.$nextTick(() => {
      const containerWidth =
        document.querySelector('.puzzle-canvas').clientWidth
      const suggestImage = document.querySelector('.suggest-image')

      if (containerWidth && suggestImage) {
        suggestImage.style.width = `${Math.ceil(containerWidth / 8)}px`
        suggestImage.style.height = `${Math.ceil(containerWidth / 8)}px`
      }
    })
  },
  mounted() {
    window.addEventListener('resize', this.resizeHandler)
    this.isShowAwser = true
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeHandler)
    clearInterval(this.timerInterval)
  },
  methods: {
    playGame() {
      this.isPlaying = true

      this.isShowAwser = true

      this.startTimer()
      setTimeout(() => {
        this.loadImageAndDrawPuzzle()
      }, 200)
    },
    startTimer(isPause = false) {
      this.startTime = Date.now()

      if(!isPause && this.timerInterval) clearInterval(this.timerInterval)

      this.timerInterval = setInterval(() => {
        if(!isPause) {
          this.currentTime = Math.floor((Date.now() - this.startTime) / 1000)
        }
        else {
          this.currentTime = Math.floor((Date.now() - this.startTime + this.pauseTime * 1000) / 1000)
        }

        this.updateCurrentTimeString()

        if (this.currentTime === this.maxTime) {
          this.isComplete = false
          this.endGame(this.isComplete)
        }
      }, 1000)
    },
    // continueGame() {},
    clearTimeInterval() {
      if (this.timerInterval) clearInterval(this.timerInterval)
    },
    playAgain() {
      setTimeout(() => {
        this.showModal = false

        this.currentTime = 0
        this.updateCurrentTimeString()

        this.clearCanvas()
        this.isPlaying = false
      }, 50)
    },
    endGame(result) {
      this.completeTime = this.currentTimeString

      this.clearTimeInterval()

      this.titleModalPlayAgain = result
        ? 'Chúc mừng bạn đã chiến thắng!'
        : 'Chúc bạn may mắn lần sau!'

      this.showModal = true
    },
    actionAgreeExit() {
      this.showModal = false
      this.clearTimeInterval()
      let url = '/home'
      this.$router.push(url)
    },
    actionRefureExit() {
      this.showModalExit = false
      this.startTimer(true)
      this.updateCurrentTimeString()
    },
    exitGame() {
      this.pauseTime = this.currentTime
      this.clearTimeInterval()
      this.showModalExit = true
    },
    targetSuggest() {
      const background = document.getElementById('puzzle-background')
      const suggest = document.querySelector('.suggest-image')
      if (background) background.classList.toggle('active')
      if (suggest) suggest.classList.toggle('in-focus')
    },
    // endTargetSuggest() {
    //   const background = document.getElementById('puzzle-background')
    //   const suggest = document.querySelector('.suggest-image')

    //   if (background) background.classList.remove('active')
    //   if (suggest) suggest.classList.remove('in-focus')
    // },
    loadImageAndDrawPuzzle() {
      let malharro = new Image()
      malharro.src = require('~/static/malharro.jpg')
      malharro.onload = () => {
        this.drawPuzzle(malharro)
      }
    },
    drawPuzzle(image) {
      let painterKonva = new headbreaker.painters.Konva()
      const containerWidth =
        document.querySelector('.puzzle-canvas').clientWidth
      const containerHeight =
        document.querySelector('.puzzle-canvas').clientHeight
      const pieceSize = Math.min(containerWidth, containerHeight) / 4.6

      this.autoGen = new headbreaker.Canvas('puzzle', {
        width: containerWidth,
        height: containerHeight,
        pieceSize: pieceSize,
        proximity: pieceSize * 0.15,
        borderFill: pieceSize * 0.09,
        strokeWidth: 9,
        lineSoftness: 0.18,
        image: image,
        fixed: true,
        preventOffstageDrag: true,
        painter: painterKonva,
        maxPiecesCount: 9,
      })

      

      this.autoGen.adjustImagesToPuzzleHeight()
      this.autoGen.autogenerate({
        // horizontalPiecesCount: 2,
        // verticalPiecesCount: 2,
        horizontalPiecesCount: 3,
        verticalPiecesCount: 3,
      })

      this.autoGen.shuffleGrid()
      this.autoGen.attachSolvedValidator()
      this.autoGen.onValid(() => {
        this.clearTimeInterval()
        setTimeout(() => {
          this.isComplete = true
          this.endGame(this.isComplete)
        }, 500)
      })

      this.autoGen.draw()

      const puzzle = this.autoGen.puzzle;
      puzzle['dragMode']['dragShouldDisconnect'] = ( function (piece, dx, dy) {
        console.log(1111);
          console.log(piece, dx, dy)
          return piece.horizontalConnector.openMovement(piece, dx) && piece.verticalConnector.openMovement(piece, dy);
      } );

    },

    clearCanvas() {
      this.autoGen.clear()
    },
    convertTimeToString(time) {
      // Minutes: Math.floor(time / 60)
      // Seconds: time % 60

      return `${String(Math.floor(time / 60)).padStart(2, '0')}:${String(
        time % 60
      ).padStart(2, '0')}`
    },
    updateCurrentTimeString() {
      this.currentTimeString = this.convertTimeToString(this.currentTime)
    },
  },
}
</script>

<style scoped>
#puzzle-container {
  margin: 0 !important;
  padding: 0 !important;
  width: 100vw !important;
  height: 100vh !important;
  box-sizing: border-box;
}

.container {
  margin-top: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
}

#game {
  box-sizing: border-box;
}

#game > div:first-child {
  text-align: center;
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 20px;
}

.info-user-turn {
  text-align: center;
}

.puzzle-contain {
  position: relative;
  width: 50vw;
  height: 80vh;
  margin: 0 auto;
  border: 2px solid #333;
}

.puzzle-background {
  position: absolute;
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
  width: 50vw;
  height: 80vh;
  background-image: url('~/static/malharro.jpg');
  opacity: 0.5;
}

.puzzle-canvas {
  width: 50vw;
  height: 80vh;
  margin: 0 auto;
  z-index: 2;
}

.suggest-container {
  position: absolute;
  bottom: 0px;
  left: 0;
  transition: all 0.2s linear;
  z-index: 999999;
}

.suggest-info {

}

.suggest-info:hover {
  cursor: pointer;
}

.suggest-info img {
  width: 1px;
  height: 1px;
  border: solid;
  border-radius: 4px;
  margin-left: 4px;
  transition: all 0.2s linear;
}

.suggest-btn {
  background: rgba(0, 0, 255, 0.712);
  color: #fff;
}

.suggest-btn:hover {
  background: rgb(0, 0, 255);
}

#puzzle .konvajs-content canvas {
  border: none !important;
}

/* Button styling */
button {
  display: block;
  margin: 0 auto;
  padding: 10px 20px;
  font-size: 18px;
  font-weight: bold;
  border: none;
  border-radius: 5px;
  background-color: #007bff;
  color: #fff;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #0056b3;
}

/* Modal styling */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background-color: #fff;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

/* Modal title styling */
.modal-content h2 {
  text-align: center;
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 20px;
}

/* Modal button container */
.modal-buttons {
  display: flex;
  justify-content: space-around;
  margin-top: 20px;
}

.active {
  z-index: 99;
  opacity: 1;
}

.in-focus {
  opacity: 0.5;
}

@media only screen and (max-width: 320px) {
  #game > div:first-child {
    font-size: 18px;
    margin-bottom: 10px;
  }

  .info-user-turn p {
    font-size: 12px;
    margin-bottom: 8px;
  }

  button {
    padding: 6px 12px;
    font-size: 14px;
  }

  .modal-content h2 {
    font-size: 18px;
    margin-bottom: 10px;
  }
}

@media only screen and (min-width: 321px) and (max-width: 375px) {
  #game > div:first-child {
    font-size: 22px;
    margin-bottom: 15px;
  }

  .info-user-turn p {
    font-size: 14px;
    margin-bottom: 10px;
  }

  button {
    padding: 8px 16px;
    font-size: 16px;
  }

  .modal-content h2 {
    font-size: 24px;
    margin-bottom: 15px;
  }
}
</style>
