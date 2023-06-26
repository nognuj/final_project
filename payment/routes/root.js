'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: 'root payment 끝낼 수 있을까?' }
  })
}
