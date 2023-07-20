import dynamic from 'next/dynamic'
import type { NextPage } from 'next'
import { getStations } from '#components/GeoFootball/slice'
import PageLayout from '#components/PageLayout'
import styles from '#styles/GeoFootball.module.css'
import { GroupedStations, Station } from '#components/GeoFootball/types'

const GeoFootballMap = dynamic(() => import('../components/GeoFootball/index'), { ssr: false })
interface Properties {
	stationsByCountry: GroupedStations,
}

export async function getServerSideProps() {
	let stationsByCountry = {}
	const response = await getStations()
	if (response.ok) {
		const stations = await response.json() as Station[]

		stationsByCountry = stations.reduce((clusters: any, station: Station) => {
			clusters[station.country] = clusters[station.country] || []
			clusters[station.country].push(station)
			return clusters
		}, {}) as GroupedStations
	}

	return {
		props: {
			stationsByCountry,
		},
	}
}

const GeoFootballPage: NextPage<Properties> = ({ stationsByCountry }) => {
	return (
		<PageLayout title="Geo-Football on Rails" hero={false} className={styles['geo-football']}>
			<GeoFootballMap stationsByCountry={stationsByCountry} />
		</PageLayout >
	)
}

export default GeoFootballPage
