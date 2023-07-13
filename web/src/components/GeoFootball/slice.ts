import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { AppState } from '#store'
import type { Station } from './types'

export interface GeoFootballState {
	latitude: number,
	longitude: number,
}

const initialState = {
	latitude: 0,
	longitude: 50,
} as GeoFootballState


const BASE_URL = process.env.API_URL || process.env.NEXT_PUBLIC_API_URL

async function GET(path: string) {
	console.log('BASE_URL = ', BASE_URL)
	const response = await fetch(`${BASE_URL}${path}`)
	return await response.json()
}

async function POST(path: string, data: string) {
	return fetch(`${BASE_URL}${path}`, {
		body: data,
		headers: {
			'Content-Type': 'application/json',
		},
		method: 'POST',
	})
}

export async function getStationsByCountry(): Promise<object> {
	const stations = await GET('/stations') as Array<Station>
	return stations.reduce((clusters: any, station: Station) => {
		clusters[station.country] = clusters[station.country] || []
		clusters[station.country].push(station)
		return clusters
	}, {});
}

export async function saveStation(station: Station): Promise<object> {
	console.log(`BASE_URL = ${BASE_URL}`)
	return POST('/stations', JSON.stringify(station))
}

const slice = createSlice({
	name: 'responsive',
	initialState,
	reducers: {
		get(state) {
			return state
		},
	}
})

export default slice.reducer
