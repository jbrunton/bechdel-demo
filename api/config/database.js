module.exports = {
  development: {
    username: 'postgres',
    password: 'postgres_password',
    database: 'bechdel_demo_development',
    host: process.env.POSTGRES_HOST || '127.0.0.1',
    dialect: 'postgres',
    operatorsAliases: false
  },
  test: {
    username: 'postgres',
    password: 'postgres_password',
    database: 'bechdel_demo_test',
    host: process.env.POSTGRES_HOST || '127.0.0.1',
    dialect: 'postgres',
    operatorsAliases: false
  },
  production: {
    username: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DATABASE,
    host: process.env.POSTGRES_HOST,
    dialect: 'postgres',
    operatorsAliases: false
  }
};
