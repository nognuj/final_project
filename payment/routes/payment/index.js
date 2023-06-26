'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/payment 어디로 떠나볼까' }
  })

  fastify.get('/abc', async function (request, reply) {
    return { root: '/payment 우주로가쨔!' }
  })
}
