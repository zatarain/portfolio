import { render, screen } from '@testing-library/react'
import IndexPage from '#pages'

jest.mock('#hooks', () => ({
	useCV: () => ({
		data: {
			name: 'My Name'
		}
	})
}))

describe('<IndexPage />', () => {
	it('renders the home page', () => {
		render(<IndexPage />)
		expect(screen.getByText('My Name')).toBeInTheDocument()
	})
})
