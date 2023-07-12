import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { AppState } from '#store'

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

export function getStations(): Promise<{ data: Station[] }> {
	return GET('/stations')
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
