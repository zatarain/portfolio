import { render, screen } from '@testing-library/react'
import { Provider } from 'react-redux'
jest.mock('#hooks', () => ({
	useCV: () => ({
		data: {
			name: 'This is my name'
		}
	})
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

		expect(screen.getByText('This is my name')).toBeInTheDocument()
	})
})
