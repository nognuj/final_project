'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/payment ci / cd branch test 이것이 진정한 정답이란 말인가./... 안녕할 수 없어요 죄송합니다' }
  })
}
