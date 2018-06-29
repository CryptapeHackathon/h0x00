<template>
  <div>
    <div class="chain-header">
      <span>列表</span>
    </div>

    <div class="chain-items">
      <div class="item-page row" v-for="order in orders">
        <img src="https://s.gravatar.com/avatar/e07957839319470aa6851c6c9be9077c?s=80" alt="Coin Logo" class="">

        <div class="second">
          <div>{{ order.takerTokenName }} / {{ order.takerChainName }}</div>
          <small>价格: {{ order.makerTokenName }} / {{ order.makerChainName }}</small>
        </div>

        <div class="third">
          <div>{{ order.takerAmount }}</div>
          <small>{{ order.makerAmount }}</small>
        </div>

        <a class="submit-order">
          <i class="icon-shopping-cart"></i>
          <span>下单</span>
        </a>
      </div>
    </div>

    <footer>
      <a href="#" class="active">
        <i class="icon-list"></i>
        <span>列表</span>
      </a>

      <a href="#">
        <i class="icon-sell"></i>
        <span>出售</span>
      </a>

      <a href="#">
        <i class="icon-sell"></i>
        <span>Ex</span>
      </a>
    </footer>
  </div>
</template>

<script>
export default {
  data: function() {
    return {
      orders: [
        {
          takerTokenName: "AAPO",
          takerChainName: "Apollo",
          makerTokenName: "BBAR",
          makerChainName: "Barney",
          takerAmount: 150,
          makerAmount: 200
        },
        {
          takerTokenName: "AAPO",
          takerChainName: "Apollo",
          makerTokenName: "BBAR",
          makerChainName: "Barney",
          takerAmount: 100,
          makerAmount: 200
        }
      ]
    };
  }
};
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
