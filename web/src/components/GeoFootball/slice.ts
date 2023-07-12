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


const BASE_URL = process.env.API_URL || ''

async function GET(path: string) {
	const response = await fetch(`${BASE_URL}${path}`)
	return await response.json()
}

export async function getStations(): Promise<Map<string, Station[]>> {
	const stations = await GET('/stations') as Array<Station>
	return stations.reduce((clusters: any, station: Station) => {
		clusters[station.country] = clusters[station.country] || []
		clusters[station.country].push(station)
		// console.log(clusters)
		return clusters
	}, {});
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
