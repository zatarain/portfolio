import { createSlice } from '@reduxjs/toolkit'
import { AppState } from '#store'

export interface ResponsiveState {
	value: boolean
}

const initialState = { value: false } as ResponsiveState

const slice = createSlice({
	name: 'responsive',
	initialState,
	reducers: {
		flip(state) {
			state.value = !state.value
		},
		close(state) {
			state.value = false
		}
	}
})

export const flipResponsiveMenu = slice.actions.flip
export const closeResponsiveMenu = slice.actions.close
export const selectResponsive = (state: AppState) => state.responsive.value
export default slice.reducer
