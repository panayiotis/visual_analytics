export default {
  schema: {
    type: '',
    fields: {
      nuts: {
        name: 'nuts',
        level: '1',
        levels: ['0', '1', '2', '3'],
        drill: [null, null, null, null]
      },
      date: {
        name: 'date',
        level: 'year',
        levels: ['year', 'month'],
        drill: [null, null]
      },
      reported_by: {
        name: 'reported_by',
        level: null,
        levels: [],
        drill: []
      },
      crime_type: {
        name: 'crime_type',
        level: '1',
        levels: ['1', '2'],
        drill: [null, null]
      }
    },
    view: 'view'
  }
}
