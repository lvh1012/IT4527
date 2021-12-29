<template>
  <footer id="footer" class="w-100 side d-flex align-items-center justify-content-between">
    <img class="logo" style="height:3rem" src="@/assets/logo2.png" />
    <div class="p-2"></div>
    <div class="d-flex flex-column ">
      <div class="small d-flex justify-content-end">Bùi Văn Tuyên - 20202409M</div>
      <div class="small d-flex justify-content-end">Nghiêm Tiến Tuân - 20211040M</div>
      <div class="small d-flex justify-content-end">Phùng Mạnh Long - 20202399M</div>
      <div class="small d-flex justify-content-end">Lê Viết Hoàng - 20173128</div>
      <div class="small d-flex justify-content-end">© 2021 Bản quyền thuộc Nhóm 4 IT4327</div>
    </div>
  </footer>
</template>

<script>
export default {
  data() {
    return {};
  },
  methods: {},
};
</script>

<style>
#footer {
  height: 6rem;
  background-color: rgba(54,54,54,0.77);
  color: #f1f1f1;
}

.small{
    font-size: .6em !important;
}
</style>
