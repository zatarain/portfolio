import dynamic from 'next/dynamic'
import type { NextPage } from 'next'
import { getStations } from '#components/GeoFootball/slice'
import type { Station } from '#components/GeoFootball/types'
import PageLayout from '#components/PageLayout'

const GeoFootballMap = dynamic(() => import('../components/GeoFootball/index'), { ssr: false })
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
			<GeoFootballMap stations={stations} />
		</PageLayout >
	)
}

export default GeoFootballPage
