<template>
  <v-list class="mb-4 mt-2">
    <v-list-item v-for="list in lists" :key="list.id" :to="{ name: 'List', params: { id: list.id, parentTab: parentTab }}">
      <v-list-item-content>
        <v-list-item-title class="primary--text">
          {{list.title}}
          <v-tooltip right>
            <template v-slot:activator="{ on }">
              <v-icon x-small v-on="on" v-if="showPrivacy" :color="list.public ? 'grey lighten-1' : null">
                {{ list.public ? 'mdi-lock-open-variant' : 'mdi-lock' }}
              </v-icon>
            </template>
            <span>{{ list.public ? 'This list is public' : 'This list is private'}}</span>
          </v-tooltip>
        </v-list-item-title>
        <v-list-item-subtitle class="text--primary" v-text="list.description" />
        <v-list-item-subtitle v-if="list.user" class="caption">Author: {{list.user.name}}</v-list-item-subtitle>
      </v-list-item-content>
      <v-list-item-action class="d-flex flex-row align-center">
        <v-btn icon class="mr-4" v-if="list.average_rating != null"
        :to="{ name: 'ListCharts', params: { id: list.id, parentTab: parentTab }}">
          <v-icon color="pink">mdi-chart-timeline-variant</v-icon>
        </v-btn>
        <Rating v-bind:rating="list.average_rating" v-if="list.average_rating != null" :showScore="true" />
      </v-list-item-action>
    </v-list-item>
  </v-list>
</template>

<script>
import Rating from '@/components/Rating';

export default {
  props: {
    lists: Array,
    parentTab: String,
    showPrivacy: Boolean
  },
  components: {
    Rating    
  }
}
</script>