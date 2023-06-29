import { render, screen } from '@testing-library/react'
import IndexPage, { getServerSideProps } from '#pages'

jest.mock('react-responsive-carousel/lib/styles/carousel.min.css', () => ({}))

jest.mock('next/font/google', () => ({
	Inter: () => ({
		className: 'inter-font-class'
	})
}))

global.fetch = jest.fn(() =>
	Promise.resolve({
		json: () => Promise.resolve({
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
					achievements: 'dummy contributions paragraph',
				},
				{
					role: 'dummy role intern',
					type: 'part-time',
					company: 'same company',
					city: 'another city',
					country: 'same country',
					start: '06/2021',
					end: '09/2021',
					achievements: 'dummy contributions paragraph as intern',
				},
			],
		}),
	})
);

beforeEach(() => {
	fetch.mockClear()
});

describe('<IndexPage />', () => {
	it('renders the home page', () => {
		const data = {
			name: 'My Name'
		}
		render(<IndexPage data={data} />)
		expect(screen.getByText('My Name')).toBeInTheDocument()
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
							achievements: 'dummy contributions paragraph',
						},
						{
							role: 'dummy role intern',
							type: 'part-time',
							company: 'same company',
							city: 'another city',
							country: 'same country',
							start: '06/2021',
							end: '09/2021',
							achievements: 'dummy contributions paragraph as intern',
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
