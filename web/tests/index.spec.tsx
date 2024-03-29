import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import IndexPage, { getServerSideProps } from '#pages'

jest.mock('react-responsive-carousel/lib/styles/carousel.min.css', () => ({}))

jest.mock('next/font/google', () => ({
	Inter: () => ({
		className: 'inter-font-class'
	})
}))

const testData = {
	name: 'My Test Name',
	education: [
		{
			school: 'dummy school',
			grade: 'BSc Dummy Career',
			start: 2019,
			end: 2021,
			gpa: 90,
			'relevant-subjects': [
				'hello',
				'world',
			],
		},
		{
			school: 'dummy research centre',
			grade: 'MSc Dummy Career',
			thesis: 'Dummy Thesis Topic',
			start: 2021,
			end: 2023,
			gpa: 95,
			'relevant-subjects': [
				'hello master',
				'world master',
			],
		},
	],
	'work-experience': [
		{
			role: 'dummy role',
			type: 'full-time',
			company: 'dummy company',
			city: 'dummy city',
			country: 'dummy country',
			start: '10/2021',
			end: '10/2022',
			contributions: 'dummy contributions paragraph',
		},
		{
			role: 'dummy role intern',
			type: 'part-time',
			company: 'same company',
			city: 'another city',
			country: 'same country',
			start: '06/2021',
			end: '09/2021',
			contributions: 'dummy contributions paragraph as intern',
		},
	],
}

global.fetch = jest.fn(() =>
	Promise.resolve({
		json: () => Promise.resolve(testData),
	})
)

beforeEach(() => {
	fetch.mockClear()
})

describe('<IndexPage />', () => {
	it('renders the home page', () => {
		const { getByText } = render(
			<Provider store={store}>
				<IndexPage data={testData} />
			</Provider>
		)
		expect(getByText('My Test Name')).toBeInTheDocument()
	})
})

describe('getServerSideProps', () => {
	it('fetches the curriculum data properly from API', async () => {
		const result = await getServerSideProps()

		expect(fetch).toHaveBeenCalledTimes(1)
		expect(result).toEqual({
			props: {
				data: {
					name: 'My Test Name',
					education: [
						{
							school: 'dummy school',
							grade: 'BSc Dummy Career',
							start: 2019,
							end: 2021,
							gpa: 90,
							subjects: [
								'hello',
								'world',
							],
						},
						{
							school: 'dummy research centre',
							grade: 'MSc Dummy Career',
							thesis: 'Dummy Thesis Topic',
							start: 2021,
							end: 2023,
							gpa: 95,
							subjects: [
								'hello master',
								'world master',
							],
						},
					],
					experience: [
						{
							role: 'dummy role',
							type: 'full-time',
							company: 'dummy company',
							city: 'dummy city',
							country: 'dummy country',
							start: '10/2021',
							end: '10/2022',
							contributions: 'dummy contributions paragraph',
						},
						{
							role: 'dummy role intern',
							type: 'part-time',
							company: 'same company',
							city: 'another city',
							country: 'same country',
							start: '06/2021',
							end: '09/2021',
							contributions: 'dummy contributions paragraph as intern',
						},
					],
					projects: [],
					skills: [],
					social: [],
				}
			}
		})
	})
})
