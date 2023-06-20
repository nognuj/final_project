'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/funding', async function (request, reply) {
    return { root: 'funding rw' }
  })
}
