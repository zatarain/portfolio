import dynamic from 'next/dynamic'
import type { NextPage } from 'next'
import { getStations } from '#components/GeoFootball/slice'
import type { Station } from '#components/GeoFootball/types'
import PageLayout from '#components/PageLayout'
import styles from '#styles/GeoFootball.module.css'

const GeoFootballMap = dynamic(() => import('../components/GeoFootball/index'), { ssr: false })
interface Properties {
	stationsByCountry: any,
}

export async function getServerSideProps() {
	const stationsByCountry = await getStations()
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
