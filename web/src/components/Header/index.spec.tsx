import { render } from '@testing-library/react'
import Header from '.'

describe('<Header />', () => {
	it('renders the component correctly with passed name', () => {

		const { asFragment, getByText } = render(<Header data={{ name: 'My Name' }} />)

		expect(getByText('My Name')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
