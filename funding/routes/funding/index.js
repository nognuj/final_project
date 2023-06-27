'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read only 뭐를 바꿔요?ㅎ' }
  })

}
