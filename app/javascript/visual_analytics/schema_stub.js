export default {
  type: 'struct',
  fields: {
    crime_type: {
      name: 'crime_type',
      level: null,
      levels: [],
      drill: []
    },
    reported_by: {
      name: 'reported_by',
      level: null,
      levels: [],
      drill: []
    },
    date: {
      name: 'date',
      level: 'month',
      levels: ['month', 'year'],
      drill: [null, null]
    },
    last_outcome_category: {
      name: 'last_outcome_category',
      level: null,
      levels: [],
      drill: []
    },
    falls_within: {
      name: 'falls_within',
      level: null,
      levels: [],
      drill: []
    },
    nuts: {
      name: 'nuts',
      level: '3',
      levels: ['3', '2', '1', '0'],
      drill: [null, null, null, null]
    }
  },
  view: 'view'
}
