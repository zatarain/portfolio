import { render } from '@testing-library/react'
import Footer from '.'

describe('<Footer />', () => {
	it('renders the component correctly', () => {
		const { asFragment } = render(<Footer />)

		expect(asFragment()).toMatchSnapshot()
	})
})
