import type { NextPage } from 'next'
import { getStations } from '#components/GeoFootball/slice'
import type { Station } from '#components/GeoFootball/types'
import PageLayout from '#components/PageLayout'
import GeoFootball from '#components/GeoFootball'

interface Properties {
	stations: Station[],
}

export async function getServerSideProps() {
	const stations = await getStations()
	return {
		props: {
			stations,
		},
	}
}

const GeoFootballPage: NextPage<Properties> = ({ stations }) => {
	return (
		<PageLayout title="Ulises/Geo-Football" hero={false}>
			<GeoFootball stations={stations} />
		</PageLayout >
	)
}

export default GeoFootballPage
