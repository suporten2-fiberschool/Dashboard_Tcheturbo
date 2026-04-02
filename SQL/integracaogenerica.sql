CREATE TABLE IF NOT EXISTS "integracao_generica" (
    "destino" varchar(50),
    "lido" boolean,
    "dt_lido" date,
    "cancelado" boolean,
    "id" serial NOT NULL UNIQUE,
    "dt_criado" date,
    "xml" text,
    "origem" varchar(50),
    PRIMARY KEY ("id")
);