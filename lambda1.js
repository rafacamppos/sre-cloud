'use strict';


module.exports.handle = async (event, context, callback) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Mensagem recebida com sucesso ',
      input: event,
    }),
  };

  callback(null, response);

};
