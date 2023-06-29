import { render } from '@testing-library/react'
import { Provider } from 'react-redux'
import { makeStore } from '#store'
import CurriculumVitae from '.'

describe('<CurriculumVitae />', () => {
	it('renders the component', () => {
		const store = makeStore()
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
		const { asFragment, getByText } = render(
			<Provider store={store}>
				<CurriculumVitae data={data} />
			</Provider>
		)

		expect(getByText('Test statement paragraph')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
