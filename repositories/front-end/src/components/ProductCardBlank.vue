<template>
  <div
    v-bind:class="['product-card--' + layout, {'product-card--sharedscreen' : sharedScreenConfig , 'is-split':isForSplitScreen, 'card-size' :  cardZise }, 'card-size--' + cardZise  ]"
    class="product-card product-card--blank">
    <div v-bind:style="isForSplitScreen ? 'width: 110px !important;height: 110px !important;min-height: 110px !important;min-width: 110px !important;' : ''" class="icon"></div>
    <div class="message">
      Out of stock
    </div>
    <div
    v-if="indexOrder"
    class="product-card__out-of-stock">
      <span>{{indexOrder}}</span>
    </div>
  </div>
</template>

<script>
// import $ from 'jquery'

export default {
  name: 'ProductCardBlank',
  props: {
    layout: String,
    sharedScreenConfig: Boolean,
    isForSplitScreen: Boolean,
    cardZise: Number,
    product: Object,
    indexOrder: Number
  },
  data () {
    return {}
  },
  created: function () {
  },
  methods: {
  }
}
</script>

<style scoped lang="scss">
  .product-card {
    position: relative;
    display:flex;
    flex-direction: column;
    justify-content:center;
    align-items: center;

      &__out-of-stock{
        font-size: 16px;
        position: absolute;
        bottom: 10px;
        left: 20px;
      }

      &.is-split{
        flex: 1;
        background:rgba(255, 255, 255, 0.1);
        padding:1rem;
        border-radius: 40px;
        min-width: 170px;
        width: 170px;
        &:not(:last-child){
          margin-right: 1rem;
        }
        .icon{
          width: 150px !important;
          height: 150px;
        }
      }
    .icon {
      ///margin: 180px 40px 0;
      margin: 0 auto;
      position: relative;
      width: auto;
      height:auto;
      max-width: 220px !important;
      min-width: 160px !important;
      max-height: 220px !important;
      min-height: 160px !important;

      border: 8px solid $white;
      border-radius: 50%;
      opacity: 0.1;

      &:before {
        display: block;
        position: absolute;
        top: 50%;
        left: 50%;
        width: 8px;
        height: 100%;

        background: $white;
        content: '';
        transform: translate3d(-50%, -50%, 0) rotate(45deg);
      }
    }

    .message {
      margin: 35px 0 0;

      opacity: 0.5;

      font: 0.55em/1.1 var(--font-light);
      letter-spacing: 0.25em;
      text-align: center;
      text-transform: uppercase;

      @at-root .app--tablet & {
        font-family: var(--font-bold);
      }
    }

    &--full {
      background: rgba($white, 0.05);
      border-radius: 30px;
    }
  }
  .product-card--sharedscreen{
    min-width: calc(16.6% - 40px ) !important;
    .product-card__inner{
    padding-left: 10px !important ;
    padding-right: 10px !important;
  }
  }
  .card-size {

    justify-content: center;

    &.card-size--1{
      width: 100% !important;
    }
    &.card-size--2{
      width: 50% !important;
    };
    &.card-size--3{
      width: 33.33% !important;
    };
    &.card-size--4{
      width: 25% !important;
    };
    &.card-size--5{
      width: 20% !important;
    };
    &.card-size--6{
      width: 16% !important;
    };
    &.card-size--7{
      width: 14% !important;
    };
    &.card-size--8{
      width: 12.5% !important;
    };
    &.card-size--9{
      width: 11.1% !important;
    };
    &.card-size--10{
      width: 10% !important;
    }
  }
</style>
