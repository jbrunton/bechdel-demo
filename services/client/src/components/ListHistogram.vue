<template>
  <div v-if="showHistogram" id="histogram-container">
    <div id="histogram">
      <div v-for="block in histogram" :key="block.rating" :style="block.style" />
    </div>

    <v-row id="histogram-legend">
      <v-col v-for="block in histogram" :key="block.rating">
        <RatingToolTip :rating="block.rating">
          <span class="legend-info">
            <v-badge :color="block.color" :inline="true" :content="block.count.toString()"></v-badge>
            <span class="legend-count">scored {{ block.rating }} </span>
            <span class="legend-percentage">({{ block.percentage.toFixed(1) }}%)</span>
          </span>
        </RatingToolTip>
      </v-col>
    </v-row>
  </div>
</template>

<style scoped>
  #histogram-container {
    background-color:#fbfbfb;
    border-bottom: solid 1px #f5f5f5;
  }
  #histogram {
    height: 10px;
  }
  #histogram div {
    height: 10px;
    vertical-align: top;
    display: inline-block;
  }

  #histogram-legend {
    text-align: center;
    font-size: 14px;
    font-weight: bold;
  }
  #histogram-legend .legend-percentage {
    color: #888;
  }
  .legend-info {
    cursor: default;
  }
</style>

<script>
import RatingToolTip from '@/components/RatingToolTip';

export default {
  props: {
    movies: Array
  },
  components: {
    RatingToolTip
  },
  computed: {
    showHistogram() {
      return !!this.movies && this.movies.length > 0;
    },
    histogram() {
      return [0, 1, 2, 3].map(rating => {
        const count = this.movies.filter(movie => movie.rating == rating).length;
        const percentage = count / this.movies.length * 100;
        const colors = ['#C62828', '#EF9A9A', '#90CAF9', '#1E88E5'];
        return {
          rating: rating,
          label: rating.toString(),
          count: count,
          percentage: percentage,
          color: colors[rating],
          style: {
            width: percentage + '%',
            'background-color': colors[rating]
          }
        }
      });
    }
  }
}
</script>