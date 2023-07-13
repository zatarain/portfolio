import dynamic from 'next/dynamic'
import type { NextPage } from 'next'
import { getStationsByCountry } from '#components/GeoFootball/slice'
import PageLayout from '#components/PageLayout'
import styles from '#styles/GeoFootball.module.css'
import { Station } from '#components/GeoFootball/types'

const GeoFootballMap = dynamic(() => import('../components/GeoFootball/index'), { ssr: false })
interface Properties {
	stationsByCountry: object,
}

export async function getServerSideProps() {
	const stationsByCountry = await getStationsByCountry()
	return {
		props: {
			stationsByCountry,
			api: process.env.API_URL || '',
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
