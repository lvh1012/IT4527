<template>
  <header id="header" class="w-100 side d-flex d-flex align-items-center justify-content-between">
    <img class="logo col-3" src="@/assets/logo.png" />
    <div class="d-flex flex-column col-6">
      <div class="uppercase black bold">Đại học Bách khoa hà nội</div>
      <div class="uppercase black bold">TRƯỜNG CÔNG NGHỆ THÔNG TIN VÀ TRUYỀN THÔNG</div>
    </div>
    <div class="col-3 d-flex align-items-center justify-content-end">     
    </div>
  </header>
</template>

<script>
export default {

};
</script>

<style>
#header {
  height: 6rem;
}

.logo {
  height: 5rem;
  margin: 0.5rem;
}

.uppercase {
  text-transform: uppercase;
}

.bold {
  font-weight: bold;
  letter-spacing: 0.05em;
  line-height: 1.5;
}

.black{
    color: black;
}
</style>
