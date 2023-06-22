'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/payment ci / cd branch test 이것이 진다' }
  })
}
