<template>
  <div
    v-bind:class="'graphs--' + size"
    class="graphs">
    <div
      v-for="graph in graphs"
      v-bind:key="graph.label"
      v-bind:class="'graph--' + graph.type + ' graph--' + graph.type + '--' +  graphs.length"
      class="graph">
      <template v-if="graph.type === 'circle'">
        <div class="graph__line">
          <svg xmlns="http://www.w3.org/2000/svg" width="130" height="130" viewBox="0 0 130 130">
            <circle fill="none" stroke="rgba(255,255,255,0.2)" stroke-width="8" stroke-miterlimit="8" cx="65" cy="65" r="61"/>
            <circle fill="none" v-bind:stroke="graph.color" stroke-dasharray="383" v-bind:stroke-dashoffset="383 - (383 * graph.percent)" stroke-linecap="round" stroke-width="8" stroke-miterlimit="8" cx="65" cy="65" r="61"/>
          </svg>
        </div><!-- .graph__line -->

        <div v-bind:style="{ color: graph.color }" class="graph__content">
          <div class="graph__label">
            {{ graph.label }}
          </div><!-- .graph__label -->

          <div class="graph__value">
            {{addPercentage(graph.value, graph.label) }}
          </div><!-- .graph__value -->
        </div><!-- .graph__content -->
      </template>

      <template v-else-if="graph.type === 'text-percent'">
        <div v-bind:style="{ color: graph.color }" class="graph__content">
          <div class="graph__label">
              {{ graph.label }}
          </div><!-- .graph__label -->

          <div class="graph__value">
            {{addPercentage(graph.value, graph.label) }}
          </div><!-- .graph__value -->
        </div><!-- .graph__content -->
      </template>

      <template v-else-if="graph.type === 'gauge'">
        <div class="graph__line">
          <svg xmlns="http://www.w3.org/2000/svg" width="170" height="170" viewBox="0 0 170 170">
            <circle fill="none" stroke="rgba(255,255,255,0.2)" stroke-width="16" stroke-dasharray="484" stroke-dashoffset="242" stroke-miterlimit="16" stroke-linecap="round"  cx="85" cy="85" r="77"/>
            <circle fill="none" v-bind:stroke="graph.color" stroke-dasharray="484" v-bind:stroke-dashoffset="484 -(242 * graph.percent)" stroke-width="16" stroke-miterlimit="10" stroke-linecap="round"  cx="85" cy="85" r="77"/>
          </svg>
        </div><!-- .graph__line -->

        <div v-bind:style="{ color: graph.color }" class="graph__content">
          <div class="graph__label">
            {{ graph.label }}
          </div><!-- .graph__label -->

          <div class="graph__value">
            {{addPercentage( graph.value, graph.label) }}
          </div><!-- .graph__value -->

          <span class="graph__limit graph__limit--min">
            {{ graph.min }}
          </span><!-- .graph__limit -->

          <span class="graph__limit graph__limit--max">
            {{ graph.max }}
          </span><!-- .graph__limit -->
        </div><!-- .graph__content -->
      </template>
    </div><!-- .graph -->

    <div v-if="copyright" class="product__copyright product__copyright--graphs">
      <div class="product__copyright__label">
        Powered by
      </div>

      <img src="/static/img/logo-wikileaf.svg" class="product__copyright__logo product__copyright__logo--wikileaf" v-if="copyright && copyright.toLowerCase().indexOf('wikileaf') !== -1" />

      <img src="/static/img/logo-potguide.svg" class="product__copyright__logo product__copyright__logo--potguide" v-if="copyright && copyright.toLowerCase().indexOf('potguide') !== -1" />
    </div><!-- .product__copyright -->
  </div><!-- .graphs -->
</template>

<script>
export default {
  name: 'ProductGraphs',
  props: {
    attributes: Object,
    copyright: String,
    layout: String,
    useBrand: Number,
    size: {
      type: String,
      default: 'small'
    }
  },
  data: function () {
    return {

    }
  },
  methods: {
    addPercentage (string, label = 'THC') {
      if (
        this.isPOSTypeEqualToTreez(this.$config.POS_TYPE) &&
        this.isTHCorCBD(label) &&
        !this.doesIncludeMG(string) &&
        !this.doesIncludePercentage(string)
      ) {
        return `${string}mg`
      }
      if (
        (!this.isPOSTypeEqualToTreez(this.$config.POS_TYPE) ||
        !this.isTHCorCBD(label)) &&
        !this.doesIncludeMG(string) &&
        !this.doesIncludePercentage(string)
      ) {
        return `${string}%`
      }
      return string
    },
    isPOSTypeEqualToTreez (posType) {
      return this.$config.POS_TYPE === 'treez'
    },
    isTHCorCBD (label) {
      return ['thc', 'cbd'].includes(label.toLowerCase())
    },
    doesIncludeMG (string) {
      return string.toLowerCase().includes('mg')
    },
    doesIncludePercentage (string) {
      return string.includes('%')
    }
  },

  computed: {
    graphs: function () {
      if (this.attributes && this.attributes.ungrouped) {
        let graphs = []

        this.attributes.ungrouped.forEach(function (attribute) {
          if (parseFloat(attribute.value) > 0) {
            if (attribute.name.toUpperCase() === 'THC') {
              graphs.push({
                type: 'circle',
                color: '#e21d92',
                label: 'THC',
                value: attribute.value,
                percent: Number(attribute.value.replace('%', '')) / 100
              })
            } else if (attribute.name.toUpperCase() === 'CBD') {
              graphs.push({
                type: 'circle',
                color: '#21a0de',
                label: 'CBD',
                value: attribute.value,
                percent: Number(attribute.value.replace('%', '')) / 100
              })
            }
            // else if (attribute.name.toUpperCase() === 'THCA') {
            //   graphs.push({
            //     type: 'circle',
            //     color: '#00c796',
            //     label: 'THCa',
            //     value: attribute.value,
            //     percent: Number(attribute.value.replace('%', '')) / 100
            //   })
            // }
          }

          // TODO: link graphs to API
          // graphs.push({
          //   type: 'text-percent',
          //   color: '#21a0de',
          //   label: 'ABV',
          //   value: '4.8'
          // })

          // graphs.push({
          //   type: 'gauge',
          //   color: '#21a0de',
          //   label: 'IBU',
          //   value: '60',
          //   percent: 0.5,
          //   min: 1,
          //   max: 120
          // })
        })

        return graphs
      }
      return false
    }
  }
}
</script>

<style scoped lang="scss">
  .graphs {
    display: flex;
    align-items: center;
    flex-direction: row;
    justify-content: flex-start;
    flex-wrap: wrap;

    &--small {
      flex-direction: row;
      justify-content: center;
      gap: 0.3em;
      .graph {
        margin-bottom: 0;

        &--circle {
          width: 2.7em;
          height: 2.7em;

          .graph__content {
            font-size: 0.5em;
            line-height: 1.2;
          }
        }

        &--circle--2{
          width: 3.5em;
          height: 3.5em;
        }

        &--circle--1{
          width: 6em;
          height: 6em;
            .graph__content {
            font-size: 0.8em;
            line-height: 1.2;
          }
        }

        &--text-percent {
          height: 3em;
          .graph__content {
            font-size: 0.8em;
          }
        }

        &--gauge {
          width: 6.5em;
          height: 5em;

          .graph__content {
            font-size: 0.8em;
          }

          .graph__line {
            width: 6.5em;
            height: 3.25em;

            svg {
              width: 6.5em;
              height: 6.5em;
            }
          }
        }
      }
    }

    &--medium {
      .graph{
        margin-right: 20px;
      }
    }
  }

  .graph {
    margin: 0;
    position: relative;

    &:first-child {
      margin-left: 0;
    }

    &:last-child {
      margin-right: 0;
    }

    &__line {
      position: absolute;
      width: 100%;
      height: 100%;

      svg {
        display: block;
        width: 100%;
        height: 100%;
      }
    }

    &--circle {
      width: 6.5em;
      height: 6.5em;

      .graph__line {
        top: 0;
        left: 0;

        transform: rotateZ(-90deg);
      }

      .graph__content {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate3d(-50%, -50%, 0);

        font: 0.7em/1.428 var(--font-semibold);
        letter-spacing: 0.2em;
        text-align: center;
        text-transform: uppercase;
      }
    }

    &--text-percent {
      margin: 0 1em;
      height: 6.5em;

      .graph__content {
        font: 0.7em/1.428 var(--font-semibold);
        letter-spacing: 0.2em;
        text-align: center;
        text-transform: uppercase;
      }

      .graph__label {
        position: absolute;
        top: -5px;
        left: 0;
        width: 100%;
      }

      .graph__value {
        margin: 0.53em 0 0;

        font: 3.8em var(--font-extralight);
      }
    }

    &--gauge {
      margin: 0 1em;
      width: 8.5em;
      height: 6.5em;

      .graph__content {
        font: 0.7em/1.428 var(--font-semibold);
        letter-spacing: 0.2em;
        text-align: center;
        text-transform: uppercase;
      }

      .graph__label {
        position: absolute;
        top: -5px;
        left: 0;
        width: 100%;
      }

      .graph__value {
        position: absolute;
        bottom: 0.41em;
        left: 0;
        width: 100%;

        font: 1.85em var(--font-extralight);
        letter-spacing: 0.01em;
      }

      .graph__line {
        bottom: 1.3em;
        left: 0;
        width: 8.5em;
        height: 4.25em;

        svg {
          width: 8.5em;
          height: 8.5em;
          transform: rotateZ(180deg);
        }
      }

      .graph__limit {
        position: absolute;
        bottom: -0.4em;
        width: 3em;

        transform: translate3d(-50%, 0, 0);

        text-align: center;

        &--min {
          left: 0.4em;
        }
        &--max {
          left: calc( 100% - 0.4em );
        }
      }
    }
  }
</style>
