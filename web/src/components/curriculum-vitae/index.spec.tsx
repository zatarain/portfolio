import { render } from '@testing-library/react'
import CurriculumVitae from '.'

describe('<CurriculumVitae />', () => {
	it('renders the component', () => {
		const data = {
			name: 'My Test Name',
			statement: 'Test statement paragraph',
			experience: [
				{

				},
			],
			education: [
				{

				},
			],
			projects: [
				{

				},
			],
			awards: [

			],
			leadership: 'Test leadership paragraph',
			volunteering: 'Test volunteering paragraph',
		}
		const { asFragment, getByText } = render(<CurriculumVitae data={data} />)

		expect(getByText('Test statement paragraph')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
