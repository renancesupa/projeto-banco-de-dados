create table empreendedor(
	id_empreendedor serial primary key,
	nome varchar not null unique
);

create table municipio(
	id_municipio serial primary key,
	nome varchar not null,
	uf varchar(2) not null,
	unique(nome, uf)
);

create table orgao_fiscalizador(
	id_orgao_fiscalizador serial primary key,
	nome varchar not null unique
);

create table tipo_material(
	id_tipo_material serial primary key,
	nome varchar not null unique
);

create table fase_vida(
	id_fase_vida serial primary key,
	nome varchar not null unique
);

create table regiao_hidrografica(
	id_regiao_hidrografica serial primary key,
	nome varchar not null unique
);

create table curso_dagua(
	id_curso_dagua serial primary key,
	nome varchar not null unique
);

create table comite_federal(
	id_comite_federal serial primary key,
	nome varchar not null unique
);

create table comite_estadual(
	id_comite_estadual serial primary key,
	nome varchar not null unique
);

create table unidade_gestao(
	id_unidade_gestao serial primary key,
	nome varchar not null unique
);

create table barragem(
    cod_snisb varchar primary key,
    cod_fiscalizador varchar not null unique,
    nome varchar not null,

    altura_fundacao_m numeric not null
        check(altura_fundacao_m >= 0),

    altura_terreno_m numeric
        check(altura_terreno_m >= 0),

    capacidade_reservatorio numeric not null
        check(capacidade_reservatorio >= 0),

    data_cadastro date not null,

    tipo_material integer
        references tipo_material(id_tipo_material),

    uso_principal varchar not null,

    latitude numeric not null
        check(latitude between -90 and 90),

    longitude numeric not null
        check(longitude between -180 and 180),

    regulada_pnsb boolean not null,

    empreendedor integer not null
        references empreendedor(id_empreendedor),

    municipio integer not null
        references municipio(id_municipio),

    fase_vida integer
        references fase_vida(id_fase_vida),

    orgao_fiscalizador integer not null
        references orgao_fiscalizador(id_orgao_fiscalizador),

    numero_autorizacao varchar not null,
    data_autorizacao date,

    regiao_hidrografica integer not null
        references regiao_hidrografica(id_regiao_hidrografica),

    cod_trecho_curso_dagua varchar,

    curso_dagua integer not null
        references curso_dagua(id_curso_dagua),

    dominio_curso_dagua varchar,

    comite_federal integer
        references comite_federal(id_comite_federal),

    comite_estadual integer
        references comite_estadual(id_comite_estadual),

    unidade_gestao integer
        references unidade_gestao(id_unidade_gestao),

    possui_pae boolean,
    possui_plano_seguranca boolean not null,
    possui_revisao_periodica boolean not null,

    categoria_risco varchar not null
        check(categoria_risco in ('Baixo', 'Médio', 'Alto')),

    dano_potencial_associado varchar not null
        check(dano_potencial_associado in ('Baixo', 'Médio', 'Alto')),

    barragem_autuada boolean not null,
    completude_cadastro varchar not null
);
