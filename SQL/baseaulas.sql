CREATE TABLE IF NOT EXISTS "baseaulas" (
	"id" serial NOT NULL UNIQUE,
	"curso" varchar(150),
	"aula" varchar(150),
	"link1" text,
	"link2" text,
	"tempo" interval,
	PRIMARY KEY ("id")
);
