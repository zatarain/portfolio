export interface Station {
	id: number,
	name: string,
	slug: string,
	country: string,
	time_zone: string,
	latitude: number,
	longitude: number,
	location: string,
	info_en: string,
	info_es: string,
}

export interface Stadium {
	id: number,
	name: string,
	slug: string,
	team: string,
	latitude: number,
	longitude: number,
	location: string,
}
