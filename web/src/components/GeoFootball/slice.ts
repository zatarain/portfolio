import type { Station } from './types'

export interface GeoFootballState {
	latitude: number,
	longitude: number,
}

const BASE_URL = process.env.API_URL || process.env.NEXT_PUBLIC_API_URL

async function GET(path: string) {
	return await fetch(`${BASE_URL}${path}`, {
		headers: {
			'Content-Type': 'application/json',
		},
		method: 'GET',
	})
}

async function POST(path: string, data: string): Promise<Response> {
	return await fetch(`${BASE_URL}${path}`, {
		body: data,
		headers: {
			'Content-Type': 'application/json',
		},
		method: 'POST',
	})
}

async function DELETE(path: string): Promise<Response> {
	return await fetch(`${BASE_URL}${path}`, {
		headers: {
			'Content-Type': 'application/json',
		},
		method: 'DELETE',
	})
}

export async function getStations(): Promise<Response> {
	return GET('/stations')
}

export async function saveStation(station: Station): Promise<Response> {
	return POST('/stations', JSON.stringify(station))
}

export async function deleteStation(id: number): Promise<Response> {
	return DELETE(`/stations/${id}`)
}

export function flag(country: string) {
	const points = country
		.toUpperCase()
		.split('')
		.map((char) => 127397 + char.charCodeAt(0));
	return String.fromCodePoint(...points);
}
