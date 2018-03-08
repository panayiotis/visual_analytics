export const dateToQuarter = date => {
  var quarter
  const month = date.getMonth()
  if (month < 3) quarter = 0
  else if (month < 6) quarter = 3
  else if (month < 9) quarter = 6
  else quarter = 9
  return new Date(date.getFullYear(), quarter, 1)
}
