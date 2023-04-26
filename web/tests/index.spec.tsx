import { render, screen } from '@testing-library/react'
import IndexPage from '#pages'

jest.mock('react-responsive-carousel/lib/styles/carousel.min.css', () => ({}))

jest.mock('next/font/google', () => ({
	Inter: () => ({
		className: 'inter-font-class'
	})
}))

describe('<IndexPage />', () => {
	it('renders the home page', () => {
		const data = {
			name: 'My Name'
		}
		render(<IndexPage data={data} />)
		expect(screen.getByText('My Name')).toBeInTheDocument()
	})
})
