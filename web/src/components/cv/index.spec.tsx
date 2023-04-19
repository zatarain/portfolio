import { render, screen } from '@testing-library/react'
import { Provider } from 'react-redux'
jest.mock('#services/portfolio', () => ({
	getData: () =>
		new Promise<{ data: object }>((resolve) => {
			const data = {}
			return setTimeout(() => resolve({ data }), 500)
		}),
}))

import { makeStore } from '#store'
import CurriculumVitae from '.'

describe('<CurriculumVitae />', () => {
	it('renders the component', () => {
		const store = makeStore()

		render(
			<Provider store={store}>
				<CurriculumVitae />
			</Provider>
		)

		expect(screen.getByText('Ulises Tirado Zatarain')).toBeInTheDocument()
	})
})
