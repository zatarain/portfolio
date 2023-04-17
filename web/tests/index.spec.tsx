import { render, screen } from '@testing-library/react'
import IndexPage from '#pages'

describe('<IndexPage />', () => {
	it('renders the home page', () => {

		render(<IndexPage />)

		expect(screen.getByText('It works!')).toBeInTheDocument()
		expect(screen.getByText('Hello World!')).toBeInTheDocument()
	})
})
