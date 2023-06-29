import { configureStore, ThunkAction, Action, createSlice } from '@reduxjs/toolkit'

export function makeStore() {
  const responsiveFlipper = createSlice({
    name: 'flipper',
    initialState: {
      responsive: false,
    },
    reducers: {
      flipResponsive: (state) => {
        state.responsive = !state.responsive
      }
    }
  })
  return configureStore({
    reducer: { flipper: responsiveFlipper.reducer },
  })
}

const store = makeStore()

export type AppState = ReturnType<typeof store.getState>

export type AppDispatch = typeof store.dispatch

export type AppThunk<ReturnType = void> = ThunkAction<
  ReturnType,
  AppState,
  unknown,
  Action<string>
>

export default store
