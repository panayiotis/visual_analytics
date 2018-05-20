import { schemaToHash } from '../../actions/engine.js'
import schemaStub from '../../schema_stub.js'

describe('schemaToHash', () => {
  it('should digest schema to the same hash as Scala code', () => {
    const expected = 'view63c55'
    expect(schemaToHash(schemaStub)).toMatch(expected)
  })
})
