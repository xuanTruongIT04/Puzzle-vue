<template lang="">
  <div>
    <!-- Modal -->
    <div class="play-again" v-if="showModalExit">
      <div class="modal" id="modal-one" >
        <div class="modal-dialog">
          <div class="modal-header">
            <span class="btn-close" @click="cancel()">×</span>
          </div>
          <div class="modal-body">
            <p><b>Bạn có chắc chắn muốn thoát game?</b></p>
          </div>
          <div class="modal-footer">
            <button class="btn btn-reject" @click="confirmExit()">Rời đi</button>
            <button class="btn" @click="cancelExit()">Ở lại</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  props: {
    showModalExit: {
      type: Boolean,
      require: true
    },
  },
  methods: {
    confirmExit() {
      this.$emit("confirmExit")
    },

     cancelExit() {
      this.$emit("cancelExit")
    },
  }

}
</script>
<style scoped>
.play-again {
  color: #333333;
  font-family: 'Helvetica', arial;
  height: 1500px;
}
.wrap {
  padding: 40px;
  text-align: center;
}
hr {
  clear: both;
  margin-top: 40px;
  margin-bottom: 40px;
  border: 0;
  border-top: 1px solid #aaaaaa;
}
h1 {
  font-size: 30px;
  margin-bottom: 40px;
}
p {
  margin-bottom: 20px;
}
.btn {
  background: #428bca;
  border: #357ebd solid 1px;
  border-radius: 3px;
  color: #fff;
  display: inline-block;
  font-size: 14px;
  padding: 8px 15px;
  text-decoration: none;
  text-align: center;
  min-width: 60px;
  position: relative;
  transition: all 0.1s ease;
}

.btn-reject {
  background: rgb(143, 88, 88) !important;
}

.btn-reject:hover {
  background: rgb(173, 7, 7) !important;
}

.btn:hover {
  background: #357ebd;
  cursor: pointer;
}
.btn.btn-big {
  font-size: 18px;
  padding: 15px 20px;
  min-width: 100px;
}
.btn-close {
  color: #aaaaaaad;
  font-size: 30px;
  text-decoration: none;
  position: absolute;
  right: 5px;
  top: 0;
}
.btn-close:hover {
  color: #313131;
  cursor: pointer;
}
.modal:target:before {
  display: none;
}
.modal:before {
  content: '';
  display: block;
  background: rgba(0, 0, 0, 0.6);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 10;
}
.modal .modal-dialog {
  background: #fefefe;
  border: #333333 solid 1px;
  border-radius: 5px;
  margin-left: -200px;
  position: fixed;
  left: 50%;
  z-index: 11;
  width: 360px;
  -webkit-transform: translate(0, 0);
  -ms-transform: translate(0, 0);
  transform: translate(0, 0);
  -webkit-transition: -webkit-transform 0.3s ease-out;
  -moz-transition: -moz-transform 0.3s ease-out;
  -o-transition: -o-transform 0.3s ease-out;
  transition: transform 0.3s ease-out;
  top: 20%;
}
.modal:target .modal-dialog {
  top: -100%;
  -webkit-transform: translate(0, -500%);
  -ms-transform: translate(0, -500%);
  transform: translate(0, -500%);
}
.title {
  color: blue;
}
.modal-body {
  padding: 8px 20px;
}
.modal-header,
.modal-footer {
  padding: 10px 20px;
}
.modal-header {
  border-bottom: #eeeeee solid 1px;
}
.modal-header h2 {
  font-size: 20px;
}
.modal-footer {
  border-top: #eeeeee solid 1px;
  text-align: right;
}
</style>
